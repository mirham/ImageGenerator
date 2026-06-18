//
//  FileService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import Foundation

final class FileService: FileServiceType {
    private var currentTempFolder: URL?
    
    func getAppSupportFolder() -> URL? {
        let result = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask).first
        
        return result
    }
    
    func makeTempFileUrl(
        number: Int,
        suffix: String,
        outputUrl: URL,
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
                    appropriateFor: outputUrl,
                    create: true
                )
            } catch {
                tempFolder = outputUrl
                    .deletingLastPathComponent()
                    .appendingPathComponent(
                        Constants.tempFolder,
                        isDirectory: true)
                
                try FileManager.default.createDirectory(
                    at: tempFolder,
                    withIntermediateDirectories: true
                )
            }
            
            currentTempFolder = tempFolder
        }
        
        let fileExt = ext ?? outputUrl.pathExtension
        let fileName = String(
            format: Constants.vfTempFileUrl,
            suffix,
            number,
            fileExt
        )
        
        return tempFolder.appendingPathComponent(fileName)
    }
    
    func makeFolder(at: URL) throws {
        try FileManager.default.createDirectory(
            at: at,
            withIntermediateDirectories: true)
    }
    
    func doesFileExist(filePath: String) -> Bool {
        let fileManager = FileManager.default
        let result = fileManager.fileExists(atPath: filePath)
        
        return result
    }
    
    func doesFolderExist(folderPath: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        let result = fileManager.fileExists(
            atPath: folderPath,
            isDirectory: &isDir)
        && isDir.boolValue
        
        return result
    }
    
    func getFileSize(at url: URL) -> Int? {
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        
        return attrs?[.size] as? Int
    }
    
    func copy(
        at source: URL,
        toFolder folder: URL,
        withNewName name: String) throws {
        let destination = folder.appending(
            path: name,
            directoryHint: .notDirectory)
        
        try FileManager.default.copyItem(
            atPath: source.path,
            toPath: destination.path)
    }
    
    func copy(at source: URL, to destination: URL) throws {
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        
        try FileManager.default.copyItem(at: source, to: destination)
    }
    
    func deleteFileAsync(at url: URL) async throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func wipeTempFolder() throws {
        if let folder = currentTempFolder {
            try FileManager.default.removeItem(at: folder)
        }
        
        currentTempFolder = nil
    }
}
