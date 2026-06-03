//
//  AviVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory
import Foundation

final class AviVideoGenerationStrategy: VideoGenerationStrategyType {
    let format: VideoOutputFormat = .avi
    let isSupportsStreamLoop: Bool = false
    
    func getCodecArguments(for videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration:
                return durationArguments()
            case .fileSize(let bytes):
                let bitrate = calculateBitrate(for: bytes)
                
                return fileSizeArguments(bitrate: bitrate)
        }
    }
    
    func padFile(to url: URL, padding: Int) {
        guard padding > 0
        else { return }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: url)
            
            defer { try? fileHandle.close() }
            
            try fileHandle.seekToEnd()
            
            let maxChunkData = Int(UInt32.max) - 8
            var remaining = padding
            
            while remaining > 0 {
                guard remaining >= 8
                else {
                    writeZeros(
                        fileHandle: fileHandle,
                        count: remaining
                    )
                    
                    break
                }
                
                let chunkTotal = min(remaining, maxChunkData + 8)
                let chunkData = chunkTotal - 8
                
                let typeData = "JUNK".data(using: .ascii)!
                var chunkSize = UInt32(chunkData).littleEndian
                let sizeData = Data(bytes: &chunkSize, count: 4)
                
                try fileHandle.write(contentsOf: typeData)
                try fileHandle.write(contentsOf: sizeData)
                
                if chunkData > 0 {
                    writeZeros(
                        fileHandle: fileHandle,
                        count: chunkData
                    )
                }
                
                remaining -= chunkTotal
            }
        } catch {
            print("AVI padding failed: \(error)")
        }
    }
    
    func trimFile(
        sourceUrl: URL,
        targetBytes: Int,
        outputUrl: URL) -> Bool {
        guard let sourceSize = getFileSize(at: sourceUrl)
        else { return false }
        
        let undershoot = Int(Double(targetBytes) * Constants.undershootFactor)
        
        do {
            try FileManager.default.copyItem(at: sourceUrl, to: outputUrl)
        } catch {
            return false
        }
        
        if sourceSize <= targetBytes {
            let padding = targetBytes - sourceSize
            
            if padding > 0 {
                padFile(to: outputUrl, padding: padding)
            }
            
            return true
        }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: outputUrl)
            
            try fileHandle.truncate(atOffset: UInt64(undershoot))
            try fileHandle.close()
        } catch {
            return false
        }
        
        padFile(
            to: outputUrl,
            padding: targetBytes - undershoot)
        
        return true
    }
    
    // MARK: Private functions
    
    private func durationArguments() -> [String] {
        [
            "-c:v", "libx264",
            "-preset", "ultrafast",
            "-crf", "28",
            "-g", "600",
            "-bf", "0",
            "-tune", "fastdecode",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func fileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "libx264",
            "-preset", "ultrafast",
            "-b:v", "\(bitrate)",
            "-g", "600",
            "-bf", "0",
            "-tune", "fastdecode",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func calculateBitrate(for targetBytes: Int) -> Int {
        let maxBitrate = 50_000_000
        let minBitrate = 1_000_000
        
        let targetDuration = max(
            10.0,
            Double(targetBytes) * 8.0 / Double(maxBitrate)
        )
        let bitrate = Int(Double(targetBytes) * 8.0 / targetDuration)
        
        return max(minBitrate, min(maxBitrate, bitrate))
    }
    
    private func getFileSize(at url: URL) -> Int? {
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attrs?[.size] as? Int
    }
}
