//
//  AutomaticLists.swift
//  SmartNote
//
//  Created by Martin on 15.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation

extension NSRange {
    func toRange(string: String) -> Range<String.Index> {
        let startIndex = string.startIndex.advancedBy(location)
        let endIndex = startIndex.advancedBy(length)
        return startIndex..<endIndex
    }
}

class AutomaticBulletAndNumberLists:NSObject{
    
    static func automaticContinue(textView:CustomTextView, range:NSRange)->Bool
    {
        if(!self.outContinueListsForTextView(textView, range: range)){
            return self.outContinueCheckmarksForTextView(textView, range: range)
        }
        return true
    }
    
    static func outContinueListsForTextView(textView:CustomTextView,range:NSRange)->Bool{
        if range.length > 0 {
            return true
        }
        
        if textView.attributedString().length == 0 {
            return true
        }
        
        
        let currentPos = textView.selectedRange().location
        //let nextCharFromCurrentPos = CharAndString.getChar(textView.textStorage!.string, index: currentPos)!.stringValue
        
        if let nextCharFromCurrentPos = CharAndString.getChar(textView.string!, index: currentPos)?.charValue {
            if nextCharFromCurrentPos == 0x2022 {
                return true
            }
        }
        var location = currentPos-1
        var insertedText = false
        var isNewline = false
        while !isNewline {
            if location < 0 {location=0}
            let prevCharStr:NSString = CharAndString.getChar(textView.string!, index: location)!.stringValue
            let newlinecharset = NSCharacterSet.newlineCharacterSet()
            
            if prevCharStr.rangeOfCharacterFromSet(newlinecharset).location != NSNotFound || location == 0 {
                isNewline = true
                
                if let c =  CharAndString.getChar(textView.string!, index: currentPos-1)?.charValue{
                    if c == 0x2022{
                        textView.string?.removeAtIndex((textView.string?.startIndex.advancedBy(currentPos-1))!)
                        //textView.string?.removeAtIndex((textView.string?.startIndex.advancedBy(currentPos))!)
                        let newRange = NSRange(location: currentPos-1, length: 0)
                        textView.setSelectedRange(newRange)
                        break
                    }
                }
                
                let nextLocation:Int = (location == 0 ? location : location+1)
                if nextLocation == 0 || textView.attributedString().length > nextLocation {

                    let charAndString:CharAndString = CharAndString.getChar(textView.string!, index: nextLocation)!
                    if charAndString.charValue == 0x2022 {
                        let autoBulletString:NSString = NSString(format: "\n%C", 0x2022)
                        
                        let newText:NSString = textView.string!.stringByReplacingCharactersInRange(range.toRange(textView.attributedString().string), withString: autoBulletString as String)
                        //textView.resignFirstResponder()
                        textView.string = newText as String
                        
                        let newRange = NSRange(location: range.location+autoBulletString.length, length: 0)
                        //textView.becomeFirstResponder()
                        textView.setSelectedRange(newRange)
                        insertedText=true
                    }
                }
                break
            }
            location--
            
        }
        return !insertedText
    }
    
    static func outContinueCheckmarksForTextView(textView:CustomTextView,range:NSRange)->Bool{
        if range.length > 0 {
            return true
        }
        
        if textView.attributedString().length == 0 {
            return true
        }
        
        let currentPos = textView.selectedRange().location
        if currentPos<textView.attributedString().length{
            if let attribute = textView.attributedString().attribute(NSAttachmentAttributeName, atIndex: currentPos, effectiveRange: nil) {
   
                if let _ = attribute.attachmentCell as? CheckmarkAttachmentCell {
                    return true
                }
            }
        }
        
        if currentPos-1 < textView.attributedString().length && currentPos-1 >= 0 {
            if let attribute = textView.attributedString().attribute(NSAttachmentAttributeName, atIndex: currentPos-1, effectiveRange: nil) {
                if let _ = attribute.attachmentCell as? CheckmarkAttachmentCell {
                    textView.textStorage?.deleteCharactersInRange(NSRange(location: currentPos-1,length: 1))
                    return false
                }
            }
        }
        
        var location = currentPos-1
        var insertedText = false
        var isNewline = false
        while !isNewline {
            if location < 0 {location=0}
            
            if currentPos<textView.attributedString().length {
                if let attribute = textView.attributedString().attribute(NSAttachmentAttributeName, atIndex: currentPos, effectiveRange: nil) {
                    if let _ = attribute.attachmentCell as? CheckmarkAttachmentCell {
                        return true
                    }
                }
            }
            
            
            if let prevChar = CharAndString.getChar(textView.attributedString().string, index: location){
                
                let prevCharStr:NSString = prevChar.stringValue
                let newlinecharset = NSCharacterSet.newlineCharacterSet()
                
                if prevCharStr.rangeOfCharacterFromSet(newlinecharset).location != NSNotFound || location == 0 {
                    isNewline = true
                    
                    let nextLocation:Int = (location == 0 ? location : location+1)
                    if nextLocation == 0 || textView.attributedString().length > nextLocation {
                        
                        if nextLocation < textView.attributedString().length {
                            if let attribute = textView.attributedString().attribute(NSAttachmentAttributeName, atIndex: nextLocation, effectiveRange: nil) {
                                if let _ = attribute.attachmentCell as? CheckmarkAttachmentCell {
                                    let myattachmentCell = CheckmarkAttachmentCell(checked:false)
                                    //myattachmentCell.image?.size = NSSize(width: 12, height: 12)
                                    let myattachment = CheckmarkAttachment()
                                    myattachment.attachmentCell = myattachmentCell
                                    let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(string:"\n"))
                                    attributedString.appendAttributedString(NSAttributedString(attachment: myattachment))
                                    if (textView.shouldChangeTextInRange(textView.selectedRange(), replacementString:nil))
                                    {
                                        textView.textStorage?.beginEditing()
                                        textView.insertText(attributedString, replacementRange: textView.selectedRange())
                                        textView.textStorage?.endEditing()
                                        textView.didChangeText()
                                    }
                                    insertedText=true
                                }
                                
                            }
                        }
                    }
                    break
                }
                location--
            }
        }
        return !insertedText
    }
    
    
    
    static func outContinueNumberedListForTextView(textView:CustomTextView,range:NSRange)->Bool{
        if range.length > 0 {
            return true
        }
        
        if textView.attributedString().length == 0 {
            return true
        }
        
        
        let currentPos = textView.selectedRange().location
        
        if let nextCharFromCurrentPos = CharAndString.getChar(textView.string!, index: currentPos)?.stringValue {
            if nextCharFromCurrentPos == "\n" {
                return true
            }
        }
        
        var location = currentPos-1
        var insertedText = false
        var isNewline = false
        
        while !isNewline {
            if location < 0 {location=0}
            let prevCharStr:NSString = CharAndString.getChar(textView.string!, index: location)!.stringValue
            let newlinecharset = NSCharacterSet.newlineCharacterSet()

            if prevCharStr.rangeOfCharacterFromSet(newlinecharset).location != NSNotFound || location == 0 {
                isNewline = true
                
                let str = textView.attributedString().string
                let ind = self.firstIndexOfFromStartIndex(str, target: ". ", startIndex:location)
                let len = ind-location-1
                if ind == -1 || len > 5 {
                    return true
                }

                let range = NSRange(location: location+1,length: len)

                if let num = Int(str.substringWithRange(range.toRange(str))) {
                    let newNumberString:NSString = NSString(format: "\n%d. ", num+1)
                    
                    
                    if (textView.shouldChangeTextInRange(textView.selectedRange(), replacementString:nil))
                    {
                        textView.textStorage?.beginEditing()
                        textView.insertText(newNumberString, replacementRange: textView.selectedRange())
                        textView.textStorage?.endEditing()
                        textView.didChangeText()
                    }

                 insertedText=true
                }
            }
            location--
            
        }
        return !insertedText
    }
    
   static func firstIndexOfFromStartIndex(source:String, target: String, startIndex: Int) -> Int {
        let startRange = source.startIndex.advancedBy(startIndex)
        let range = source.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: source.endIndex))
        if let range = range {
            return source.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
}


class CharAndString:NSObject{
    let stringValue:NSString
    let charValue:UniChar
    
    init(charValue:unichar){
        self.charValue = charValue
        self.stringValue = NSString(format: "%C", charValue)
        super.init()
    }
    
    static func getChar(string:NSString, index:Int)->CharAndString? {
        if string.length == 0 || index > string.length-1{
            return nil
        }
        let thisChar = string.characterAtIndex(index)
        return CharAndString(charValue: thisChar)
    }
}