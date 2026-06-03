//
//  VideoTempFileService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation

final class VideoTempFileService: VideoTempFileServiceType {
    func makeTempVideoUrl(
        videoData: VideoData,
        suffix: String,
        ext: String? = nil) -> URL {
        let folder = videoData.outputUrl.deletingLastPathComponent()
        let fileExt = ext ?? videoData.outputUrl.pathExtension
        
        return folder.appendingPathComponent(
            String(
                format: Constants.vfTempVideoUrl,
                suffix,
                videoData.videoNumber,
                fileExt))
    }
    
    func deleteFileAsync(at url: URL) async {
        try? FileManager.default.removeItem(at: url)
    }
    
    func getFileSizeAsync(at url: URL) async -> Int? {
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        
        return attrs?[.size] as? Int
    }
    
    func writeConcatList(content: String, to url: URL) async throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}
