//
//  MovVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory
import Foundation

final class MovVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.computerService) private var computerService
    
    let format: VideoOutputFormat = .mov
    let isSupportsStreamLoop: Bool = true
    
    func getCodecArguments(for videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration:
                return computerService.isAppleSilicon()
                    ? appleSiliconDurationArguments()
                    : intelDurationArguments()
            case .fileSize(let bytes):
                let bitrate = calculateBitrate(for: bytes)
                
                return computerService.isAppleSilicon()
                    ? appleSiliconFileSizeArguments(bitrate: bitrate)
                    : intelFileSizeArguments(bitrate: bitrate)
        }
    }
    
    func padFile(to url: URL, padding: Int) throws {
        guard padding > 0
        else { return }
        
        guard padding >= 8 else {
            padWithZeros(to: url, padding: padding)
            
            return
        }
        
        let fileHandle = try FileHandle(forWritingTo: url)
        
        defer { try? fileHandle.close() }
        
        try fileHandle.seekToEnd()
        
        let typeData = Constants.vfDataFree.data(using: .ascii)!
        
        if padding <= Int(UInt32.max) {
            var boxSize = UInt32(padding).bigEndian
            let sizeData = Data(bytes: &boxSize, count: 4)
            
            try fileHandle.write(contentsOf: sizeData)
            try fileHandle.write(contentsOf: typeData)
        } else {
            guard padding >= 16
            else {
                padWithZeros(to: url, padding: padding)
                
                return
            }
            
            var marker = UInt32(1).bigEndian
            let markerData = Data(bytes: &marker, count: 4)
            var boxSize64 = UInt64(padding).bigEndian
            let sizeData64 = Data(bytes: &boxSize64, count: 8)
            
            try fileHandle.write(contentsOf: markerData)
            try fileHandle.write(contentsOf: typeData)
            try fileHandle.write(contentsOf: sizeData64)
        }
        
        let headerSize = padding <= Int(UInt32.max) ? 8 : 16
        let dataSize = padding - headerSize
        
        if dataSize > 0 {
            writeZeros(fileHandle: fileHandle, count: dataSize)
        }
    }
    
    func trimFile(
        sourceUrl: URL,
        targetBytes: Int,
        outputUrl: URL) throws {
        return
    }
    
    // MARK: Private functions
    
    private func appleSiliconDurationArguments() -> [String] {
        [
            "-c:v", "h264_videotoolbox",
            "-allow_sw", "1",
            "-q:v", "50",
            "-realtime", "1",
            "-g", "600",
            "-bf", "0",
            "-pix_fmt", "yuv420p",
            "-movflags", "+faststart"
        ]
    }
    
    private func appleSiliconFileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "h264_videotoolbox",
            "-allow_sw", "1",
            "-realtime", "1",
            "-b:v", "\(bitrate)",
            "-g", "600",
            "-bf", "0",
            "-pix_fmt", "yuv420p",
            "-movflags", "+faststart"
        ]
    }
    
    private func intelDurationArguments() -> [String] {
        [
            "-c:v", "libx264",
            "-preset", "ultrafast",
            "-crf", "28",
            "-g", "600",
            "-bf", "0",
            "-tune", "fastdecode",
            "-pix_fmt", "yuv420p",
            "-movflags", "+faststart"
        ]
    }
    
    private func intelFileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "libx264",
            "-preset", "ultrafast",
            "-b:v", "\(bitrate)",
            "-g", "600",
            "-bf", "0",
            "-tune", "fastdecode",
            "-pix_fmt", "yuv420p",
            "-movflags", "+faststart"
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
}
