//
//  FileError.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 18.06.2026.
//

import Foundation

enum FileError: LocalizedError {
    case appSupportFolderNotFound
    case quarantineRemovalFailed(String)
    
    var errorDescription: String? {
        switch self {
            case .appSupportFolderNotFound:
                return "Application support folder could not be found"
            case .quarantineRemovalFailed(let path):
                return "Failed to remove quarantine attribute from: \(path)"
        }
    }
}
