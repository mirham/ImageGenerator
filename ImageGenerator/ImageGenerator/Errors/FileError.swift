//
//  FileError.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 18.06.2026.
//

import Foundation

enum FileError: LocalizedError {
    case appSupportFolderNotFound
    case tempFolderNotFound
    case fileNotFound(String)
    case fileNotReadable(String)
    case fileNotWritable(String)
    case directoryCreationFailed(String)
    case deletionFailed(String)
    case wipeFailed(String)
    case quarantineRemovalFailed(String)
    
    var errorDescription: String? {
        switch self {
            case .appSupportFolderNotFound:
                return "Application support folder could not be found"
            case .tempFolderNotFound:
                return "Temporary folder could not be found"
            case .fileNotFound(let path):
                return "File not found at path: '\(path)'"
            case .fileNotReadable(let path):
                return "File is not readable: '\(path)'"
            case .fileNotWritable(let path):
                return "File is not writable: '\(path)'"
            case .directoryCreationFailed(let path):
                return "Failed to create directory at: '\(path)'"
            case .deletionFailed(let path):
                return "Failed to delete file at: '\(path)'"
            case .wipeFailed(let path):
                return "Failed to wipe folder at: '\(path)'"
            case .quarantineRemovalFailed(let path):
                return "Failed to remove quarantine attribute from: \(path)"
        }
    }
}
