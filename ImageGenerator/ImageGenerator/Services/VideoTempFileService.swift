//
//  VideoTempFileService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation

final class VideoTempFileService: VideoTempFileServiceType {
    private var currentTempFolder: URL?
    
    func makeTempVideoUrl(
        videoData: VideoData,
        suffix: String,
        ext: String? = nil
    ) throws -> URL {
        let tempFolder: URL
        
        if let cached = currentTempFolder {
            tempFolder = cached
        } else {
            do {
                tempFolder = try FileManager.default.url(
                    for: .itemReplacementDirectory,
                    in: .userDomainMask,
                    appropriateFor: videoData.outputUrl,
                    create: true
                )
            } catch {
                tempFolder = videoData.outputUrl.deletingLastPathComponent()
                    .appendingPathComponent(Constants.tempFolder, isDirectory: true)
                
                try FileManager.default.createDirectory(
                    at: tempFolder,
                    withIntermediateDirectories: true
                )
            }
            
            currentTempFolder = tempFolder
        }
        
        let fileExt = ext ?? videoData.outputUrl.pathExtension
        let fileName = String(
            format: Constants.vfTempVideoUrl,
            suffix,
            videoData.videoNumber,
            fileExt
        )
        
        return tempFolder.appendingPathComponent(fileName)
    }
    
    func deleteFileAsync(at url: URL) async throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func getFileSizeAsync(at url: URL) async throws -> Int? {
        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
        
        return attrs[.size] as? Int
    }
    
    func writeConcatList(content: String, to url: URL) async throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    func wipeTempFolder() throws {
        if let folder = currentTempFolder {
            try FileManager.default.removeItem(at: folder)
        }
        
        currentTempFolder = nil
    }
}
