//
//  CIImageExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import CoreImage

extension CIImage {
    var ppi: Double {
        if let dpi = properties[kCGImagePropertyDPIWidth as String] as? Double {
            return dpi
        }
        
        let tiff = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
        let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        
        let source = tiff ?? exif
        
        guard let xResolution = source?[kCGImagePropertyTIFFXResolution as String] as? Double
        else { return Constants.defaultPpi }
        
        // 1 = no unit, 2 = inch (DPI), 3 = centimeter
        let unit = source?[kCGImagePropertyTIFFResolutionUnit as String] as? Int ?? 2
        
        switch unit {
            case 2: return xResolution // DPI
            case 3: return xResolution * 2.54 // cm → inch
            default: return Constants.defaultPpi
        }
    }
}
