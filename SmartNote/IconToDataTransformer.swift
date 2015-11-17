//
//  IconToDataTransformer.swift
//  SmartNote
//
//  Created by Martin on 21.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation

class IconToDataTransformer: NSValueTransformer {
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        let rep = value?.representations[0] as! NSBitmapImageRep
        let data = rep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
        return data;
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
       let uiImage = NSImage(data: value as! NSData);
        return uiImage;
    }
}