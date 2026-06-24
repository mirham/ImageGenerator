//
//  VideoGenerationStrategyType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

protocol VideoGenerationStrategyType {
    var fileService: FileServiceType { get }
    var format: VideoOutputFormat { get }
    var isSupportsStreamLoop: Bool { get }
    
    func getCodecArguments(for videoData: VideoData) -> [String]
    func padFile(to url: URL, padding: Int) throws
    func trimFile(sourceUrl: URL, targetBytes: Int, outputUrl: URL) throws
}

extension VideoGenerationStrategyType {
    func writeZeros(fileHandle: FileHandle, count: Int) throws {
        let chunkSize = Int(Constants.kibi * Constants.kibi)
        let fullChunk = Data(count: chunkSize)
        var remaining = count
        
        while remaining > 0 {
            let writeSize = min(remaining, chunkSize)
            let chunk = writeSize == chunkSize
                ? fullChunk
                : Data(count: writeSize)
            
            try fileHandle.write(contentsOf: chunk)
            
            remaining -= writeSize
        }
    }
    
    func padWithZeros(to url: URL, padding: Int) throws {
        guard padding > 0 else { return }
        
        let fileHandle = try FileHandle(forWritingTo: url)
        defer { try? fileHandle.close() }
        
        try fileHandle.seekToEnd()
        try writeZeros(fileHandle: fileHandle, count: padding)
    }
    
    func padFile(to url: URL, padding: Int, format: VideoPaddingFormat) throws {
        guard padding > 0
        else { return }
        
        switch format {
            case .isoBmff(let type):
                try padIsoBmff(
                    to: url,
                    padding: padding,
                    type: type)
            case .riff(let type, let maxChunkSize):
                try padRiff(
                    to: url,
                    padding: padding,
                    type: type,
                    maxChunkSize: maxChunkSize)
            case .quickTime(let voidId):
                try padQuickTime(
                    to: url,
                    padding: padding,
                    voidId: voidId)
            case .tsNullPackets:
                try padTsNullPackets(
                    to: url,
                    padding: padding)
            case .none:
                return
        }
    }
    
    func exactSizePadOnly(
        sourceUrl: URL,
        targetBytes: Int,
        outputUrl: URL,
        padFormat: VideoPaddingFormat
    ) throws {
        let sourceSize = fileService.getFileSize(at: sourceUrl) ?? 0
        
        try fileService.copy(at: sourceUrl, to: outputUrl)
        
        if sourceSize == targetBytes { return }
        
        if sourceSize < targetBytes {
            let padding = targetBytes - sourceSize
            try padFile(to: outputUrl, padding: padding, format: padFormat)
            
            return
        }
        
        throw VideoGenerationError.oversizedFile(
            actual: sourceSize,
            target: targetBytes
        )
    }
    
    func calculateBitrate(
        for targetBytes: Int,
        maxBitrate: Int,
        minBitrate: Int,
        bitrateThresholdBytes: Int = Constants.maxBitrateThresholdSize
    ) -> Int {
        guard targetBytes < bitrateThresholdBytes
        else { return maxBitrate }
        
        let sizeRatio = Double(targetBytes) / Double(bitrateThresholdBytes)
        let eased = pow(sizeRatio, Constants.quadraticExponent)
        
        let bitrate = Int(
            Double(minBitrate)
            + (Double(maxBitrate)
            - Double(minBitrate)) * eased
        )
        
        return max(minBitrate, min(maxBitrate, bitrate))
    }
    
    // MARK: Private functions
    
    private func padIsoBmff(
        to url: URL,
        padding: Int,
        type: String) throws {
        guard padding >= 8 else {
            try padWithZeros(to: url, padding: padding)
            
            return
        }
        
        let fileHandle = try FileHandle(forWritingTo: url)
        
        defer { try? fileHandle.close() }
        
        try fileHandle.seekToEnd()
        
        let typeData = type.data(using: .ascii)!
        
        if padding <= Int(UInt32.max) {
            var boxSize = UInt32(padding).bigEndian
            let sizeData = Data(bytes: &boxSize, count: 4)
            
            try fileHandle.write(contentsOf: sizeData)
            try fileHandle.write(contentsOf: typeData)
            
            let dataSize = padding - 8
            
            if dataSize > 0 {
                try writeZeros(fileHandle: fileHandle, count: dataSize)
            }
        } else {
            guard padding >= 16 else {
                try writeZeros(fileHandle: fileHandle, count: padding)
                
                return
            }
            
            var marker = UInt32(1).bigEndian
            let markerData = Data(bytes: &marker, count: 4)
            var boxSize64 = UInt64(padding).bigEndian
            let sizeData64 = Data(bytes: &boxSize64, count: 8)
            
            try fileHandle.write(contentsOf: markerData)
            try fileHandle.write(contentsOf: typeData)
            try fileHandle.write(contentsOf: sizeData64)
            
            let dataSize = padding - 16
            if dataSize > 0 {
                try writeZeros(fileHandle: fileHandle, count: dataSize)
            }
        }
    }
    
    private func padRiff(
        to url: URL,
        padding: Int,
        type: String,
        maxChunkSize: Int) throws {
        guard padding >= 8 else {
            try padWithZeros(to: url, padding: padding)
            
            return
        }
        
        let fileHandle = try FileHandle(forWritingTo: url)
            
        defer { try? fileHandle.close() }
        
        try fileHandle.seekToEnd()
        
        let maxChunkData = maxChunkSize - 8
        var remaining = padding
        
        while remaining > 0 {
            if remaining < 8 {
                let typeData = type.data(using: .ascii)!
                var chunkSize = UInt32(0).littleEndian
                let sizeData = Data(bytes: &chunkSize, count: 4)
                
                try fileHandle.write(contentsOf: typeData)
                try fileHandle.write(contentsOf: sizeData)
                
                remaining -= 8
                
                break
            }
            
            let chunkTotal = min(remaining, maxChunkData + 8)
            let chunkData = chunkTotal - 8
            
            let typeData = type.data(using: .ascii)!
            var chunkSize = UInt32(chunkData).littleEndian
            let sizeData = Data(bytes: &chunkSize, count: 4)
            
            try fileHandle.write(contentsOf: typeData)
            try fileHandle.write(contentsOf: sizeData)
            
            if chunkData > 0 {
                try writeZeros(fileHandle: fileHandle, count: chunkData)
            }
            
            remaining -= chunkTotal
        }
    }
    
    private func padQuickTime(
        to url: URL,
        padding: Int,
        voidId: UInt8) throws {
        guard padding >= 2 else {
            try padWithZeros(to: url, padding: padding)
            return
        }
        
        let fileHandle = try FileHandle(forWritingTo: url)
        
        defer { try? fileHandle.close() }
        
        try fileHandle.seekToEnd()
        
        if padding < 128 {
            let dataSize = padding - 2
            let sizeByte = UInt8(0x80 | dataSize)
            try fileHandle.write(contentsOf: Data([voidId, sizeByte]))
            
            if dataSize > 0 {
                try writeZeros(fileHandle: fileHandle, count: dataSize)
            }
        } else {
            guard padding >= 9 else {
                try writeZeros(fileHandle: fileHandle, count: padding)
                
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
            sizeBytes[7] = UInt8(sizeValue & 0xFF)
            
            try fileHandle.write(contentsOf: Data([voidId]))
            try fileHandle.write(contentsOf: sizeBytes)
            
            if dataSize > 0 {
                try writeZeros(fileHandle: fileHandle, count: dataSize)
            }
        }
    }
    
    private func padTsNullPackets(to url: URL, padding: Int) throws {
        guard padding > 0 else { return }
        
        let fileHandle = try FileHandle(forWritingTo: url)
        defer { try? fileHandle.close() }
        
        try fileHandle.seekToEnd()
        
        let packetSize = 188
        let fullPackets = padding / packetSize
        let remainder = padding % packetSize
        
        var nullPacket = Data(count: packetSize)
        nullPacket[0] = 0x47
        nullPacket[1] = 0x1F
        nullPacket[2] = 0xFF
        nullPacket[3] = 0x10
        
        for i in 4..<packetSize {
            nullPacket[i] = 0xFF
        }
        
        if fullPackets > 0 {
            let chunkPacketCount = 1024
            let chunkDataSize = chunkPacketCount * packetSize
            
            var chunk = Data(count: chunkDataSize)
            for packetOffset in stride(from: 0, to: chunkDataSize, by: packetSize) {
                chunk.replaceSubrange(packetOffset..<(packetOffset + packetSize), with: nullPacket)
            }
            
            var packetsRemaining = fullPackets
            while packetsRemaining > 0 {
                let batchSize = min(packetsRemaining, chunkPacketCount)
                let batchBytes = batchSize * packetSize
                
                let writeData = batchSize == chunkPacketCount
                ? chunk
                : Data(chunk.prefix(batchBytes))
                
                try fileHandle.write(contentsOf: writeData)
                packetsRemaining -= batchSize
            }
        }
        
        if remainder > 0 {
            try writeZeros(fileHandle: fileHandle, count: remainder)
        }
    }
}
