//
//  TextStyles.swift
//  SmartNote
//
//  Created by Martin on 21.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation


//Custom class to store a style containing font and paragraph information
class NoteTextStyle {
    let font:NSFont
    let label:String
    let paragraphStyle:NSMutableParagraphStyle
    let listType:Int
    
    init(label:String, fontFamiliyName:String,traits:NSFontTraitMask, size:CGFloat, paragraphSpacing:CGFloat, listType:Int=0){
    self.label = label
    let fontManager = NSFontManager()
    self.font = fontManager.fontWithFamily(fontFamiliyName, traits: traits, weight: 0, size: size)!
    self.paragraphStyle = NSMutableParagraphStyle()
    self.paragraphStyle.paragraphSpacing = paragraphSpacing
    self.listType = listType
    }
    
}


//Custom class to generate multiple styles
class NoteTextStyles {
    var styles: [NoteTextStyle] = []
    init(){
        let fontName="Helvetica"
        self.styles.append(NoteTextStyle(label: "Title",fontFamiliyName: fontName,traits: NSFontTraitMask.BoldFontMask,size: 18, paragraphSpacing: 10))
        self.styles.append(NoteTextStyle(label: "Heading",fontFamiliyName: fontName,traits: NSFontTraitMask.BoldFontMask,size: 15, paragraphSpacing: 8))
        self.styles.append(NoteTextStyle(label: "Text",fontFamiliyName: fontName,traits: NSFontTraitMask.UnboldFontMask,size: 13,paragraphSpacing: 6))
        self.styles.append(NoteTextStyle(label:"Numbered List",fontFamiliyName: fontName,traits: NSFontTraitMask.UnboldFontMask,size: 13,paragraphSpacing: 6,listType:1))
        
    }
}