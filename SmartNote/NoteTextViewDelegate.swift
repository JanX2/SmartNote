//
//  NoteTextViewDelegate.swift
//  SmartNote
//
//  Created by Martin on 24.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation

class NoteTextViewDelegate: NSViewController, NSTextViewDelegate {
    
    
    @IBOutlet var NoteTextView: CustomTextView!
    @IBOutlet weak var NoteTableView: NSTableView!
    @IBOutlet weak var mainViewController: MainViewController!
    
    //Handle clicks on custom attachmentcell
    func textView(textView: NSTextView, clickedOnCell cell: NSTextAttachmentCellProtocol!, inRect cellFrame: NSRect) {
        //Check if checkmark cell and toggle chechmark image
        if let checkNote = cell as? CheckmarkAttachmentCell {
            let currentSelection = textView.selectedRange()
            let range = NSRange(location: textView.characterIndexForInsertionAtPoint(NSPoint(x: cellFrame.origin.x, y: cellFrame.origin.y)), length:1)
            if (textView.shouldChangeTextInRange(range, replacementString:nil))
            {
                textView.textStorage?.beginEditing()
                
                let checked:Bool
                
                if checkNote.image!.name() == "checkmarkoff" {
                    checked = true
                }else{
                    checked = false
                }
                
                let myattachmentCell = CheckmarkAttachmentCell(checked: checked)
                let myattachment = CheckmarkAttachment()
                myattachment.attachmentCell = myattachmentCell
                let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: myattachment))
                textView.insertText(attributedString, replacementRange: range)
                
                textView.textStorage?.endEditing()
                textView.didChangeText()
                textView.setSelectedRange(currentSelection)
            }
            textView.setNeedsDisplayInRect(cellFrame)
        }
    }
    
    func textView(textView: NSTextView, doubleClickedOnCell cell: NSTextAttachmentCellProtocol!, inRect cellFrame: NSRect) {
        if let imageCell = cell as? ImageAttachmentCell {
            NSWorkspace.sharedWorkspace().openURL(imageCell.imageURL )
        }
    }
    
    //Autocompletion of lists for checkmarks and bulletlists
    func textView(textView: NSTextView, shouldChangeTextInRange affectedCharRange: NSRange, replacementString: String?) -> Bool {
        if replacementString == "\n" {
            self.NoteTextView.setStandardFontStyle()
            self.NoteTextView.setStandardParagraphStyle()
            return AutomaticBulletAndNumberLists.outContinueCheckmarksForTextView(textView as! CustomTextView, range: affectedCharRange)
        }
                return true
    }
    
    //Always update editing time of notes for rearrangement in table on change
    func textDidChange(notification: NSNotification) {
        let currentNote = self.mainViewController.getCurrentNote()
        currentNote?.setValue(NSDate(), forKey: "edittime")
        if self.mainViewController.noteArrayController.arrangedObjects[0].isEqualTo(currentNote){
            self.NoteTableView.reloadDataForRowIndexes(NSIndexSet(index: 0), columnIndexes: NSIndexSet(index: 0))
        }else{
            self.mainViewController.noteArrayController.rearrangeObjects()
        }
    }

//    func textView(view: NSTextView, draggedCell cell: NSTextAttachmentCellProtocol!, inRect rect: NSRect, event: NSEvent!) {
//        if cell.attachment?.className == CheckmarkAttachment.className() {
//        }
//    }
    
    func textView(view: NSTextView, writablePasteboardTypesForCell cell: NSTextAttachmentCellProtocol, atIndex charIndex: Int) -> [String] {
        return [NSStringPboardType, NSPasteboardTypeRTFD, NSPasteboardTypeRTF]
    }
    
    func textView(view: NSTextView, writeCell cell: NSTextAttachmentCellProtocol, atIndex charIndex: Int, toPasteboard pboard: NSPasteboard, type: String) -> Bool {
        if cell.attachment?.className == CheckmarkAttachment.className() {
            pboard.declareTypes([NSStringPboardType, NSPasteboardTypeRTFD, NSPasteboardTypeRTF], owner: self)
            
            if type == NSStringPboardType {
                pboard.setString("x", forType: type)
                return true
            } else if type == NSPasteboardTypeRTFD {
                let attStr = NSAttributedString(string: "rtfd")
                let rtfdata = attStr.RTFDFromRange(NSRange(location: 0,length: attStr.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFDTextDocumentType])
                pboard.setData(rtfdata!, forType: type)
                return true
            }else if type == NSPasteboardTypeRTF {
                let attStr = NSAttributedString(string: "rtf")
                let rtfdata = attStr.RTFFromRange(NSRange(location: 0,length: attStr.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType])
                pboard.setData(rtfdata!, forType: type)
                return true
            }
        }
        return false
    }
}