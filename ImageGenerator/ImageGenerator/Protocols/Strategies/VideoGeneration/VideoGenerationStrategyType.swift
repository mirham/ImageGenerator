//
//  VideoGenerationStrategyType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

protocol VideoGenerationStrategyType {
    var format: VideoOutputFormat { get }
    var isSupportsStreamLoop: Bool { get }
    
    func getCodecArguments(for videoData: VideoData) -> [String]
    func padFile(to url: URL, padding: Int) throws
    func trimFile(sourceUrl: URL, targetBytes: Int, outputUrl: URL) throws
}

extension VideoGenerationStrategyType {
    func writeZeros(fileHandle: FileHandle, count: Int) {
        let chunkSize = 1024 * 1024
        let fullChunk = Data(count: chunkSize)
        var remaining = count
        
        while remaining > 0 {
            let writeSize = min(remaining, chunkSize)
            let chunk = writeSize == chunkSize ? fullChunk : Data(count: writeSize)
            
            try? fileHandle.write(contentsOf: chunk)
            remaining -= writeSize
        }
    }
    
    func padWithZeros(to url: URL, padding: Int) {
        guard padding > 0
        else { return }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: url)
            
            defer { try? fileHandle.close() }
            
            try fileHandle.seekToEnd()
            
            writeZeros(fileHandle: fileHandle, count: padding)
        } catch {
            print("Zero padding failed: \(error)")
        }
    }
}
