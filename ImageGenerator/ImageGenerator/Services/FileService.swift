//
//  FileService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import Foundation

final class FileService: FileServiceType {
    private var currentTempFolder: URL?
    
    var fileManager: FileManager {
        get {
            FileManager.default
        }
    }
    
    func getAppSupportFolder() throws -> URL {
        let appSupportRootFolder = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask).first
        
        guard let rootFolder = appSupportRootFolder
        else { throw FfmpegError.appSupportUnavailable }
        
        let result = rootFolder
            .appendingPathComponent(Constants.appSupportFolder)
        
        if !doesFolderExist(folderPath: result.path) {
            try makeFolder(at: result)
        }
        
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
                tempFolder = try fileManager.url(
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
                
                try fileManager.createDirectory(
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
        try fileManager.createDirectory(
            at: at,
            withIntermediateDirectories: true)
    }
    
    func doesFileExist(filePath: String) -> Bool {
        let result = fileManager.fileExists(atPath: filePath)
        
        return result
    }
    
    func ensureFolderExists(at url: URL) throws {
        if !doesFolderExist(folderPath: url.path) {
            try makeFolder(at: url)
        }
    }
    
    func doesFolderExist(folderPath: String) -> Bool {
        var isDir: ObjCBool = false
        let result = fileManager.fileExists(
            atPath: folderPath,
            isDirectory: &isDir)
        && isDir.boolValue
        
        return result
    }
    
    func getFileSize(at url: URL) -> Int? {
        let attrs = try? fileManager.attributesOfItem(atPath: url.path)
        
        return attrs?[.size] as? Int
    }
    
    func copy(
        at source: URL,
        toFolder folder: URL,
        withNewName name: String) throws {
        let destination = folder.appending(
            path: name,
            directoryHint: .notDirectory)
            
        try ensureFolderExists(at: folder)
        try fileManager.copyItem(
            atPath: source.path,
            toPath: destination.path)
    }
    
    func copy(at source: URL, to destination: URL) throws {
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        
        let parentFolder = destination.deletingLastPathComponent()
        try ensureFolderExists(at: parentFolder)
        
        do {
            try fileManager.copyItem(at: source, to: destination)
        }
        catch {
            print(source.path)
            print(destination.path)
            print(error.localizedDescription)
        }
    }
    
    func ensureExecutable(url: URL) throws {
        guard let attrs = try? fileManager.attributesOfItem(atPath: url.path),
              let permissions = attrs[.posixPermissions] as? Int
        else { return }
        
        let executableBits = 0o111
        
        guard permissions & executableBits == 0
        else { return }
        
        try fileManager.setAttributes(
            [.posixPermissions: permissions | executableBits],
            ofItemAtPath: url.path)
    }
    
    func removeQuarantineAttribute(from url: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        process.arguments = ["-d", "com.apple.quarantine", url.path]
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw FileError.quarantineRemovalFailed(url.path)
        }
    }
    
    func deleteFileAsync(at url: URL) async throws {
        try fileManager.removeItem(at: url)
    }
    
    func wipeTempFolder() throws {
        if let folder = currentTempFolder {
            try fileManager.removeItem(at: folder)
        }
        
        currentTempFolder = nil
    }
}
