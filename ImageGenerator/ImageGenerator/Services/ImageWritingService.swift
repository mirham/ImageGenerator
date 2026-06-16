//
//  ImageWritingService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import Factory

final class ImageWritingService : ImageWritingServiceType {
    @Injected(\.imageWritingStrategyFactory) private var imageWritingStrategyFactory
    @Injected(\.fileService) private var fileService
    
    func writeImage(
        image: CIImage?,
        originalImagePath: URL?,
        options: ImageOutputOptions,
        to folder: URL) throws {
        if image == nil, let path = originalImagePath {
            try fileService.copyItem(
                at: path,
                toFolder: folder,
                withNewName: options.fileName)
            
            return
        }
        
        guard let strategy = imageWritingStrategyFactory.getStrategy(
                for: options.format,
                colorSpace: options.colorSpace,
                isAnimated: options.isAnimated),
              let image = image
        else { return }
            
        try strategy.write(
            image: image,
            options: options,
            to: folder)
    }
}
