//
//  NSImageExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 09.05.2025.
//

import SwiftUI

extension NSImage{
    var pixelSize: NSSize? {
        if let representation = self.representations.first{
            let size = NSSize(
                width: representation.pixelsWide,
                height: representation.pixelsHigh)
            
            return size
        }
        
        return nil
    }
}
