//
//  ProgressDownloader.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.06.2026.
//

import Foundation
import Factory

final class ProgressDownloader: NSObject, URLSessionDownloadDelegate {
    @Injected(\.fileService) private var fileService
    
    private var continuation: CheckedContinuation<URL, Error>?
    private var onProgress: ((Double) -> Void)?
    
    private lazy var session = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: nil)
    
    func download(
        from url: URL,
        onProgress:
        @escaping (Double) -> Void) async throws -> URL {
        self.onProgress = onProgress
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            session.downloadTask(with: url).resume()
        }
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0
        else { return }
        
        onProgress?(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let http = downloadTask.response as? HTTPURLResponse,
              http.statusCode == 200
        else {
            let status = (downloadTask.response as? HTTPURLResponse)?.statusCode
                ?? -1
            continuation?.resume(
                throwing: FfmpegError.downloadFailed(statusCode: status))
            continuation = nil
            
            return
        }
        
        let destination = fileService.fileManager
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        do {
            try FileManager.default.moveItem(at: location, to: destination)
            continuation?.resume(returning: destination)
        } catch {
            continuation?.resume(throwing: error)
        }
        
        continuation = nil
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?) {
        guard let error
        else { return }
        
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
