//
//  CustomTextView.swift
//  SmartNote
//
//  Created by Martin on 14.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation
let SNPasteboardType = "com.smartnote.pasteboardrtfstring"
let defaultFontFamily = "Helvetica"
let defaultParagraphLineSpacing:CGFloat = 6


// NSTextView which supports custom NSCellAttachments (for checkmarks, images, etc)

class CustomTextView:NSTextView {
    
    let defaultFont:NSFont
    let defaultTypingParagraphStyle:NSParagraphStyle
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        let fontManager = NSFontManager()
        self.defaultFont = fontManager.fontWithFamily(defaultFontFamily, traits: [.UnboldFontMask], weight: 0, size: 14)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = defaultParagraphLineSpacing
        self.defaultTypingParagraphStyle = paragraphStyle
        
        super.init(frame: frameRect,textContainer: container)
        self.typingAttributes[NSParagraphStyleAttributeName] = paragraphStyle
        self.font = self.defaultFont
    }
    
    required init?(coder: NSCoder) {
        let fontManager = NSFontManager()
        self.defaultFont = fontManager.fontWithFamily(defaultFontFamily, traits: [.UnboldFontMask], weight: 0, size: 14)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = defaultParagraphLineSpacing
        self.defaultTypingParagraphStyle = paragraphStyle
        
        super.init(coder: coder)
        self.typingAttributes[NSParagraphStyleAttributeName] = paragraphStyle
        self.font = self.defaultFont
    }
    
    override func awakeFromNib() {
        let fontManager = NSFontManager()
        let standardFont =  fontManager.fontWithFamily(defaultFontFamily, traits: [.UnboldFontMask], weight: 0, size: 14)!
        self.font = standardFont
        self.setStandardParagraphStyle()
    }
    
    
    func setStandardParagraphStyle(){
        //let paragraphStyle = NSMutableParagraphStyle()
        //paragraphStyle.paragraphSpacing = 6
        self.typingAttributes[NSParagraphStyleAttributeName] = self.defaultTypingParagraphStyle
    }
    
    func setStandardFontStyle(){
        //let fontManager = NSFontManager()
        //let standardFont = fontManager.fontWithFamily(defaultFontFamily, traits: [.UnboldFontMask], weight: 0, size: 14)!
        self.typingAttributes[NSFontAttributeName] = self.defaultFont
    }
    
    
    func insertCheckMark(){
        let myattachmentCell = CheckmarkAttachmentCell(checked: false)
        let myattachment = CheckmarkAttachment()
        myattachment.attachmentCell = myattachmentCell
        let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: myattachment))
        self.insertText(attributedString, replacementRange: self.selectedRange())
    }
    

    // Reading from Pasteboard
    
    override internal var readablePasteboardTypes: [String] {
        get {
            var standardtypes = super.readablePasteboardTypes
            standardtypes.append(SNPasteboardType)
            return standardtypes
        }
    }
    
    override func preferredPasteboardTypeFromArray(availableTypes: [String], restrictedToTypesFromArray allowedTypes: [String]?) -> String? {
        if availableTypes.contains(SNPasteboardType){
            return SNPasteboardType
        }else{
            return super.preferredPasteboardTypeFromArray(availableTypes, restrictedToTypesFromArray: allowedTypes)
        }
    }
    
    override func readSelectionFromPasteboard(pboard: NSPasteboard, type: String) -> Bool {
        if type == SNPasteboardType{
            if let data = pboard.dataForType(SNPasteboardType) {
                let attributedstring = NSKeyedUnarchiver.unarchiveObjectWithData(data)
                self.insertText(attributedstring!, replacementRange: self.selectedRange())
                return true
            }else{
                return false
            }
        }else if type ==  NSFilenamesPboardType {
            if let url = NSURL(fromPasteboard: pboard){
                
                let myattachmentCell = ImageAttachmentCell(fileURL: url)
                let myattachment = ImageAttachment()
                myattachment.attachmentCell = myattachmentCell
                let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: myattachment))
                self.insertText(attributedString, replacementRange: self.selectedRange())
                return true
            }else{
                return false
            }
            //return super.readSelectionFromPasteboard(pboard, type: type)
        }
        else
        {
            
            return super.readSelectionFromPasteboard(pboard, type: type)
        }
    }
    
    
    
    // Writing to Pasteboard
    
    override internal var writablePasteboardTypes: [String] {
        get {
            var standardtypes = super.writablePasteboardTypes
            standardtypes.append(SNPasteboardType)
            return standardtypes
        }
    }
    
    override func writeSelectionToPasteboard(pboard: NSPasteboard, types: [String]) -> Bool {
        pboard.declareTypes(types, owner: self)
        for type in types {
            self.writeSelectionToPasteboard(pboard, type: type)
        }
        return true
    }
    
    override func writeSelectionToPasteboard(pboard: NSPasteboard, type: String) -> Bool {
        let selectedRanges = self.selectedRanges
        let noteText = self.attributedString()
        let smartNoteString = NSMutableAttributedString()
        var newPasteString = ""
        let newRTFPasteString = NSMutableAttributedString()
        
        for value in selectedRanges{
            let range = value.rangeValue
            var startOfRange = range.location
            var currentLocation = range.location
            smartNoteString.appendAttributedString(self.attributedString().attributedSubstringFromRange(range))
            
            for ; currentLocation<(range.location+range.length); currentLocation++ {
                let characterString = noteText.attributedSubstringFromRange(NSRange(location: currentLocation,length: 1))
                let attribute = characterString.attribute(NSAttachmentAttributeName, atIndex: 0, effectiveRange: nil)
                if attribute != nil {
                    
                    if (currentLocation-1) > startOfRange {
                        let previousRange = NSRange(location: startOfRange,length: (currentLocation-startOfRange))
                        let subString = noteText.attributedSubstringFromRange(previousRange).string
                        newPasteString.appendContentsOf(subString)
                        newRTFPasteString.appendAttributedString(noteText.attributedSubstringFromRange(previousRange))
                    }
                    
                    if let checkNote = attribute?.attachmentCell as? CheckmarkAttachmentCell {
                        if checkNote.image?.name() == "checkmarkon" {
                            newPasteString.appendContentsOf("\t[x]\t")
                            newRTFPasteString.appendAttributedString(NSAttributedString(string:"\t✓\t"))
                        }else{
                            newPasteString.appendContentsOf("\t[ ]\t")
                            newRTFPasteString.appendAttributedString(NSAttributedString(string:"\t◦\t"))
                        }
                    }
                    startOfRange = (currentLocation+1)
                }
                
            }
            if (currentLocation-1) > startOfRange {
                let previousRange = NSRange(location: startOfRange,length: (currentLocation-startOfRange))
                let subString = noteText.attributedSubstringFromRange(previousRange).string
                newPasteString.appendContentsOf(subString)
                newRTFPasteString.appendAttributedString(noteText.attributedSubstringFromRange(previousRange))
            }
        }
        
        if type == NSStringPboardType {
            //pboard.declareTypes([type], owner: self)
            pboard.setString(newPasteString, forType: NSStringPboardType)
            return true
        } else if type == NSPasteboardTypeRTF {
            //pboard.declareTypes([type], owner: self)
            
            pboard.setData(newRTFPasteString.RTFFromRange(NSRange(location: 0,length: newRTFPasteString.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType]), forType: type)
            
            return true
        }else if type == NSPasteboardTypeRTFD {
            //pboard.declareTypes([type], owner: self)
            pboard.setData(newRTFPasteString.RTFDFromRange(NSRange(location: 0,length: newRTFPasteString.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFDTextDocumentType]), forType: type)
            return true
        }
        else if type == SNPasteboardType {
            //pboard.declareTypes([SNPasteboardType], owner: self)
            let data = NSKeyedArchiver.archivedDataWithRootObject(smartNoteString)
            pboard.setData(data,forType: SNPasteboardType)
            return true
        } else {
            return super.writeSelectionToPasteboard(pboard, type: type)
        }
    }
    
    
    
    func textView(view: NSTextView, writablePasteboardTypesForCell cell: NSTextAttachmentCellProtocol, atIndex charIndex: Int) -> [String] {
        return [NSStringPboardType, NSPasteboardTypeRTFD, NSPasteboardTypeRTF]
    }
    
    func textView(view: NSTextView, writeCell cell: NSTextAttachmentCellProtocol, atIndex charIndex: Int, toPasteboard pboard: NSPasteboard, type: String) -> Bool {
        
        if cell.attachment?.className == CheckmarkAttachment.className() {
            pboard.declareTypes([NSStringPboardType, NSPasteboardTypeRTFD, NSPasteboardTypeRTF], owner: self)
            
            if type == NSStringPboardType {
                // pboard.declareTypes([type], owner: self)
                pboard.setString("x", forType: type)
                return true
            } else if type == NSPasteboardTypeRTFD {
                //Swift.print("rtfd")
                //pboard.declareTypes([type], owner: self)
                let attStr = NSAttributedString(string: "rtfd")
                let rtfdata = attStr.RTFDFromRange(NSRange(location: 0,length: attStr.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType])
                pboard.setData(rtfdata!, forType: type)
                return true
            }else if type == NSPasteboardTypeRTF {
                //pboard.declareTypes([type], owner: self)
                let attStr = NSAttributedString(string: "rtf")
                let rtfdata = attStr.RTFFromRange(NSRange(location: 0,length: attStr.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType])
                pboard.setData(rtfdata!, forType: type)
                return true
            }
        }
        return false
    }
}