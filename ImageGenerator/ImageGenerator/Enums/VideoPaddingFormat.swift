//
//  VideoPaddingFormat.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 17.06.2026.
//

enum VideoPaddingFormat {
    case isoBmff(type: String)
    case riff(type: String, maxChunkSize: Int)
    case quickTime(voidId: UInt8)
    case tsNullPackets
    case none
}
