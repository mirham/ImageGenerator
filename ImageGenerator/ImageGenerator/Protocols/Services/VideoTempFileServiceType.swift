//
//  VideoTempFileServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation

protocol VideoTempFileServiceType {
    func makeTempVideoUrl(
        videoData: VideoData,
        suffix: String,
        ext: String?) throws -> URL
    func deleteFileAsync(at url: URL) async throws
    func getFileSizeAsync(at url: URL) async throws -> Int?
    func writeConcatList(content: String, to url: URL) async throws
    func wipeTempFolder() throws
}
