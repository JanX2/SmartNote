//
//  CustomTextAttachment.swift
//  SmartNote
//
//  Created by Martin on 14.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//



// With tokens : https://github.com/octiplex/OEXTokenField

import Foundation

class CheckmarkAttachment: NSTextAttachment {}

class CheckmarkAttachmentCell: NSTextAttachmentCell{
    
    init(checked:Bool) {
        if checked {
            super.init(imageCell: NSImage(named: "checkmarkon"))
        }else{
        super.init(imageCell: NSImage(named: "checkmarkoff"))
        }
    }
    
    override func cellSize() -> NSSize {
        return NSSize(width: 20, height: 14)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}



class ImageAttachment: NSTextAttachment {}

class ImageAttachmentCell: NSTextAttachmentCell{
    
    let imageURL:NSURL
    init(fileURL:NSURL) {
        let img =  NSImage(byReferencingURL: fileURL)
        let scaleFactor = 100 / img.size.width
        let imageSize = NSSize(width: img.size.width*scaleFactor, height: img.size.height*scaleFactor)
        self.imageURL = fileURL
        img.size = imageSize
        super.init(imageCell:img)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.imageURL = NSURL()
        super.init(coder: aDecoder)
    }
    
}