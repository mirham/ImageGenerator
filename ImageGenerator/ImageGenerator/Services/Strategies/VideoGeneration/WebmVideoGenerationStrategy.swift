//
//  WebmVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory
import Foundation

final class WebmVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.computerService) private var computerService
    
    let format: VideoOutputFormat = .webm
    let isSupportsStreamLoop: Bool = true
    
    func getCodecArguments(for videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration:
                return computerService.isAppleSilicon()
                    ? appleSiliconDurationArguments()
                    : intelDurationArguments()
            case .fileSize(let bytes):
                let bitrate = calculateBitrate(for: bytes)
                
                return fileSizeArguments(bitrate: bitrate)
        }
    }
    
    func padFile(to url: URL, padding: Int) throws {
        guard padding > 0
        else { return }
        
        guard padding >= 2 else {
            padWithZeros(
                to: url,
                padding: padding
            )
            
            return
        }
        
        let fileHandle = try FileHandle(forWritingTo: url)
        
        defer { try? fileHandle.close() }
        
        try fileHandle.seekToEnd()
        
        let voidId: UInt8 = 0xEC
        
        if padding < 128 {
            let dataSize = padding - 2
            let sizeByte = UInt8(0x80 | dataSize)
            
            try fileHandle.write(contentsOf: Data([voidId, sizeByte]))
            
            if dataSize > 0 {
                writeZeros(
                    fileHandle: fileHandle,
                    count: dataSize
                )
            }
        } else {
            guard padding >= 9 else {
                padWithZeros(to: url, padding: padding)
                
                return
            }
            
            let dataSize = padding - 9
            let sizeValue = UInt64(dataSize)
            var sizeBytes = Data(count: 8)
            
            sizeBytes[0] = 0x01
            sizeBytes[1] = UInt8((sizeValue >> 48) & 0xFF)
            sizeBytes[2] = UInt8((sizeValue >> 40) & 0xFF)
            sizeBytes[3] = UInt8((sizeValue >> 32) & 0xFF)
            sizeBytes[4] = UInt8((sizeValue >> 24) & 0xFF)
            sizeBytes[5] = UInt8((sizeValue >> 16) & 0xFF)
            sizeBytes[6] = UInt8((sizeValue >> 8) & 0xFF)
            sizeBytes[7] = UInt8( sizeValue & 0xFF)
            
            try fileHandle.write(contentsOf: Data([voidId]))
            try fileHandle.write(contentsOf: sizeBytes)
            
            if dataSize > 0 {
                writeZeros(fileHandle: fileHandle, count: dataSize)
            }
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
            "-c:v", "libvpx-vp9",
            "-crf", "30",
            "-b:v", "0",
            "-deadline", "realtime",
            "-cpu-used", "8",
            "-row-mt", "1",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func intelDurationArguments() -> [String] {
        [
            "-c:v", "libvpx-vp9",
            "-crf", "30",
            "-b:v", "0",
            "-deadline", "realtime",
            "-cpu-used", "8",
            "-row-mt", "1",
            "-tile-columns", "2",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func fileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "libvpx-vp9",
            "-b:v", "\(bitrate)",
            "-deadline", "realtime",
            "-cpu-used", "8",
            "-row-mt", "1",
            "-tile-columns", "2",
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
}
