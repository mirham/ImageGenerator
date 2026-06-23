//
//  VideoGenerationStateUpdate.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.06.2026.
//

struct VideoGenerationStateUpdate {
    var operationIncrement: Double? = nil
    var operationContribution: Double? = nil
    var videoCompleted: Bool = false
    var videoFailed: Bool = false
    var inProgress: Bool? = nil
    var isCancelRequested: Bool? = nil
}
