//
//  ImageWriterQueue.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 21.05.2026.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

actor ImageWriterQueue {
    private let stream: AsyncStream<WriteRequest>.Continuation
    private let task: Task<Void, Never>
    
    struct WriteRequest {
        let image: CGImage
        let url: URL
        let utType: UTType
        let onComplete: () async -> Void
    }
    
    init() {
        var continuation: AsyncStream<WriteRequest>.Continuation!
        let writeStream = AsyncStream<WriteRequest> { continuation = $0 }
        self.stream = continuation
        
        self.task = Task.detached(priority: .utility) { [writeStream] in
            for await request in writeStream {
                if Task.isCancelled { break }
                
                guard let destination = CGImageDestinationCreateWithURL(
                    request.url as CFURL,
                    request.utType.identifier as CFString,
                    1,
                    nil
                ) else { continue }
                
                CGImageDestinationAddImage(destination, request.image, nil)
                CGImageDestinationFinalize(destination)
                
                await request.onComplete()
            }
        }
    }
    
    func enqueue(
        image: CGImage,
        url: URL,
        utType: UTType,
        onComplete: @escaping () async -> Void) {
        stream.yield(
            WriteRequest(
                image: image,
                url: url,
                utType: utType,
                onComplete: onComplete
            )
        )
    }
    
    func cancelAsync() {
        task.cancel()
        stream.finish()
    }
    
    func finishAsync() async {
        if Task.isCancelled {
            cancelAsync()
            return
        }
        
        stream.finish()
        await task.value
    }
}
