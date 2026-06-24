//
//  LoggingServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol LoggingServiceType {
    var isWritingToFile: Bool { get }
    
    func getCount(for type: LogEntryType?) -> Int
    func write(message: String, type: LogEntryType)
    func writeOnce(message: String, type: LogEntryType)
    func copy()
    func clear()
    func openCurrentLog()
    func openLogsFolder()
    func suspend()
    func resume()
}
