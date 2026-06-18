//
//  FileService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import Foundation

final class FileService: FileServiceType {
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
    
    func copy(at source: URL, toFolder folder: URL, withNewName name: String) throws {
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
}
