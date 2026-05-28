//
//  CmykWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import Accelerate
import UniformTypeIdentifiers

final class CmykWritingStrategy: ImageWritingStrategyType {
    let outputFormat: ImageOutputFormat = .notSupported
    let colorSpace: ImageColorSpace = .cmyk
    
    func write(_ image: CIImage,
               to url: URL,
               colorSpace: CGColorSpace,
               quality: CGFloat,
               ppi: CGFloat,
               context: CIContext) throws {
        
        guard let cgImage = context.createCGImage(image, from: image.extent)
        else { return }
        
        var rgbFormat = vImage_CGImageFormat(
            bitsPerComponent: Constants.bitsPerComponent,
            bitsPerPixel: 32,
            colorSpace: Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB()),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
            version: 0,
            decode: nil,
            renderingIntent: .defaultIntent)
        
        var cmykFormat = vImage_CGImageFormat(
            bitsPerComponent: Constants.bitsPerComponent,
            bitsPerPixel: 32,
            colorSpace: Unmanaged.passRetained(CGColorSpaceCreateDeviceCMYK()),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            version: 0,
            decode: nil,
            renderingIntent: .defaultIntent)
        
        var rgbBuffer = vImage_Buffer()
        guard vImageBuffer_InitWithCGImage(
            &rgbBuffer,
            &rgbFormat,
            nil,
            cgImage,
            vImage_Flags(kvImageNoFlags)) == kvImageNoError
        else { return }
        
        defer { free(rgbBuffer.data) }
        
        var cmykBuffer = vImage_Buffer()
        guard vImageBuffer_Init(
            &cmykBuffer,
            rgbBuffer.height,
            rgbBuffer.width,
            32,
            vImage_Flags(kvImageNoFlags)) == kvImageNoError
        else { return }
        
        defer { free(cmykBuffer.data) }
        
        var error = kvImageNoError
        
        guard let converter = vImageConverter_CreateWithCGImageFormat(
            &rgbFormat,
            &cmykFormat,
            nil,
            vImage_Flags(kvImageNoFlags),
            &error)
        else { return }
        
        vImageConvert_AnyToAny(
            converter.takeRetainedValue(),
            &rgbBuffer,
            &cmykBuffer,
            nil,
            vImage_Flags(kvImageNoFlags))
        
        guard let cmykCGImage = vImageCreateCGImageFromBuffer(
            &cmykBuffer,
            &cmykFormat,
            nil,
            nil,
            vImage_Flags(kvImageNoFlags),
            nil)
        else { return }
        
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.tiff.identifier as CFString,
            1,
            nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality,
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
        
        CGImageDestinationAddImage(
            destination,
            cmykCGImage.takeRetainedValue(),
            properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
