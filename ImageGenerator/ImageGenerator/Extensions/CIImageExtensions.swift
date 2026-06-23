//
//  CIImageExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import CoreImage

private var ppiAssociationKey: UInt8 = 0

extension CIImage {
    var ppi: Double {
        if let cached = objc_getAssociatedObject(
            self, &ppiAssociationKey) as? Double {
            return cached
        }
        
        let result = computePpi()
        
        objc_setAssociatedObject(
            self,
            &ppiAssociationKey,
            result,
            .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        return result
    }
    
    // MARK: Private functions
    
    private func computePpi() -> Double {
        if let dpi = properties[MetadataKeys.dpiWidth] as? Double {
            return dpi
        }
        
        guard let metadata = extractMetadata()
        else { return Constants.defaultPpi }
        
        switch metadata.unit {
            case .inch:
                return metadata.xResolution
            case .centimeter:
                return metadata.xResolution * Constants.centimetersPerInch
            case .none:
                return Constants.defaultPpi
        }
    }
    
    private func extractMetadata() -> ImageMetadata? {
        let source = properties[MetadataKeys.tiffDictionary] as? [String: Any]
                  ?? properties[MetadataKeys.exifDictionary] as? [String: Any]
        
        guard let source
        else { return nil }
        
        let xResolution = extractResolution(
            from: source[MetadataKeys.tiffXResolution])
        
        guard xResolution > 0
        else { return nil }
        
        let rawUnit = source[MetadataKeys.tiffResolutionUnit] as? Int
        let unit = ResolutionUnit(rawValue: rawUnit ?? 2) ?? .inch
        
        return ImageMetadata(xResolution: xResolution, unit: unit)
    }
    
    private func extractResolution(from value: Any?) -> Double {
        switch value {
            case let number as Double: return number
            case let number as Int: return Double(number)
            case let number as NSNumber: return number.doubleValue
            case let rational as [UInt32] where rational.count == 2:
                return Double(rational[0]) / Double(rational[1])
            default: return 0
        }
    }
    
    // MARK: Inner types
    
    private enum ResolutionUnit: Int {
        case none = 1
        case inch = 2
        case centimeter = 3
    }
    
    private enum MetadataKeys {
        static let dpiWidth = kCGImagePropertyDPIWidth as String
        static let tiffDictionary = kCGImagePropertyTIFFDictionary as String
        static let exifDictionary = kCGImagePropertyExifDictionary as String
        static let tiffXResolution = kCGImagePropertyTIFFXResolution as String
        static let tiffResolutionUnit = kCGImagePropertyTIFFResolutionUnit as String
    }
    
    private struct ImageMetadata {
        let xResolution: Double
        let unit: ResolutionUnit
    }
}
