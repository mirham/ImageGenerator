//
//  NSImageExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 09.05.2025.
//

import SwiftUI

extension NSImage{
    var pixelSize: NSSize? {
        if let rep = self.representations.first{
            let size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
            return size
        }
        
        return nil
    }
}
