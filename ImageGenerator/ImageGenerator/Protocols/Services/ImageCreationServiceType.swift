//
//  ImageCreationServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 21.05.2026.
//

import CoreImage

protocol ImageCreationServiceType {
    func generate(number: Int, size: CGSize, ppi: CGFloat) -> CIImage?
    func duplicate(number: Int, source: CIImage) -> CIImage
}
