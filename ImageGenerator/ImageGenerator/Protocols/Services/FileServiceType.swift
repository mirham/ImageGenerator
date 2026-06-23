//
//  FileServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import Foundation

protocol FileServiceType {
    var fileManager: FileManager { get }
    
    func getAppSupportFolder() throws -> URL
    func makeTempFileUrl(
        number: Int,
        suffix: String,
        outputUrl: URL,
        ext: String?) throws -> URL
    func makeFolder(at: URL) throws
    func doesFileExist(filePath: String) -> Bool
    func doesFolderExist(folderPath: String) -> Bool
    func ensureFolderExists(at url: URL) throws
    func getFileSize(at url: URL) -> Int?
    func copy(at source: URL,toFolder folder: URL, withNewName name: String) throws
    func copy(at source: URL, to destination: URL) throws
    func ensureExecutable(url: URL) throws
    func removeQuarantineAttributeAsync(from url: URL) async throws
    func deleteFileAsync(at url: URL) async throws
    func wipeTempFolder() throws
}
