//
//  FileServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import Foundation

protocol FileServiceType {
    func doesFileExist(filePath: String) -> Bool
    func doesFolderExist(folderPath: String) -> Bool
    func copyItem(at source: URL,
                  toFolder folder: URL,
                  withNewName name: String) throws
}
