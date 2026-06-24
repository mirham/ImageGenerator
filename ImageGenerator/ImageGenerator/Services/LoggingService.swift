//
//  LoggingService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import AppKit
import Factory

final class LoggingService: LoggingServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.fileService) private var fileService
    
    private(set) var entriesCount = 0
    private(set) var entriesCountByType: [LogEntryType: Int] = [:]
    
    private let dedupeLock = NSLock()
    private let countLock = NSLock()
    
    private var loggedFingerprints: Set<LogFingerprint> = []
    private var isSuspended: Bool = false
    
    var isWritingToFile: Bool {
        fileService.doesFileExist(filePath: fileUrl.path)
    }
    
    private var fileUrl: URL {
        let dateString = fileDateFormatter.string(from: .now)
        return logsFolder.appendingPathComponent("\(dateString).\(Constants.logExtension)")
    }
    
    private lazy var logsFolder: URL = { getOrCreateLogsFolder() }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private let fileDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
    
    deinit {
        cleanOldLogs()
    }
    
    func getCount(for type: LogEntryType?) -> Int {
        countLock.lock()
        defer { countLock.unlock() }
        
        guard let type
        else { return entriesCount }
        
        return entriesCountByType[type, default: 0]
    }
    
    func write(message: String, type: LogEntryType = .info) {
        guard !isSuspended
        else { return }
        
        let logEntry = LogEntry(message: message, type: type)
        
        countLock.lock()
        entriesCount += 1
        entriesCountByType[type, default: 0] += 1
        countLock.unlock()
        
        writeToFile(logEntry)
        
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            appState.log.insert(logEntry, at: 0)
            
            if appState.log.count > Constants.logMaxInMemoryEntries {
                appState.log.removeLast()
            }
        }
    }
    
    func writeOnce(message: String, type: LogEntryType = .info) {
        let fingerprint = LogFingerprint(message: message, type: type)
        
        dedupeLock.lock()
        defer { dedupeLock.unlock() }
        
        guard !loggedFingerprints.contains(fingerprint)
        else { return }
        
        loggedFingerprints.insert(fingerprint)
        write(message: message, type: type)
    }
    
    func copy() {
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            let logText = appState.log
                .map { "\(self.dateFormatter.string(from: $0.date)) [\($0.type.description.uppercased())] \($0.message)" }
                .joined(separator: Constants.newline)
            
            AppHelper.copyTextToClipboard(text: logText)
        }
    }
    
    func clear() {
        entriesCount = 0
        entriesCountByType.removeAll()
        loggedFingerprints.removeAll()
        
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            appState.log.removeAll()
        }
    }
    
    func openCurrentLog() {
        guard fileService.doesFileExist(filePath: fileUrl.path)
        else { return }
        
        NSWorkspace.shared.open(fileUrl)
    }
    
    func openLogsFolder() {
        NSWorkspace.shared.open(logsFolder)
    }
    
    func suspend() {
        isSuspended = true
    }
    
    func resume() {
        isSuspended = false
    }
    
    // MARK: Private functions
    
    private func getOrCreateLogsFolder() -> URL {
        do {
            let appSupport = try fileService.getAppSupportFolder()
            let logsFolder = appSupport.appendingPathComponent(Constants.logPath)
            
            if !fileService.doesFolderExist(folderPath: logsFolder.path) {
                try fileService.fileManager.createDirectory(
                    at: logsFolder,
                    withIntermediateDirectories: true
                )
            }
            
            return logsFolder
        }
        catch {
            write(
                message: String(
                    format: Constants.lmLogFilesFolderCreationFailed,
                    error.localizedDescription),
                type: .error
            )
            
            return fileService.fileManager
                .temporaryDirectory
                .appendingPathComponent(Constants.logPath)
        }
    }
    
    private func writeToFile(_ entry: LogEntry) {
        let line = "\(dateFormatter.string(from: entry.date)) [\(entry.type.description.uppercased())] \(entry.message)\(Constants.newline)"
        
        guard let data = line.data(using: .utf8)
        else { return }
        
        if fileService.doesFileExist(filePath: fileUrl.path) {
            if let handle = try? FileHandle(forWritingTo: fileUrl) {
                handle.seekToEndOfFile()
                handle.write(data)
                try? handle.close()
            }
        } else {
            try? data.write(to: fileUrl, options: .atomic)
        }
    }
    
    private func cleanOldLogs() {
        guard let files = try? fileService.fileManager.contentsOfDirectory(
            at: logsFolder,
            includingPropertiesForKeys: [.creationDateKey])
        else { return }
        
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -Constants.logMaxLogAgeDays, to: .now)!
        
        for file in files where file.pathExtension == Constants.logExtension {
            guard let dateString = file.deletingPathExtension()
                    .lastPathComponent as String?,
                  let fileDate = fileDateFormatter.date(from: dateString),
                  fileDate < cutoffDate
            else { continue }
            
            Task {
                try? await fileService.deleteFileAsync(at: file)
            }
        }
    }
    
    // MARK: Inner types
    
    private struct LogFingerprint: Hashable {
        let message: String
        let type: LogEntryType
    }
}
