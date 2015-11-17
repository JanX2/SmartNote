//
//  MainWindowViewController.swift
//  SmartNote
//
//  Created by Martin on 06.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation
import Cocoa
import CoreData


class MainViewController: NSViewController, NSTableViewDelegate {
    
    @IBOutlet weak var mainWindow: SmartNoteMainWindow!
    @IBOutlet weak var SettingsMenuButton: NSButton!
    @IBOutlet var NoteTextView: CustomTextView!
    @IBOutlet weak var noteArrayController: NSArrayController!
    @IBOutlet weak var ApplicationDelegate: AppDelegate!
    @IBOutlet weak var SettingsMenu: NSMenu!
    @IBOutlet weak var Application: NSObject!
    @IBOutlet weak var currentReferenceTitle: NSTextField!
    @IBOutlet weak var StylesButton: NSButton!
    @IBOutlet weak var ToolbarView: NSView!
    @IBOutlet weak var StylesPopover: NSPopover!
    @IBOutlet weak var SearchFieldCell: NSSearchFieldCell!

    @IBOutlet weak var TitleBarTrackingView: NSView!
    @IBOutlet weak var NoteListTableView: NSTableView!
    
    var UserChangesTableSelection:Bool = true

    func getCurrentNote()->Note?{
        if self.noteArrayController.selectedObjects.count>0{
            return self.noteArrayController.selectedObjects[0] as? Note
        }else
        {
            return nil
        }
    }
    
    //Ghostmode toggle
    @IBAction func ghostmodeButtonPressed(sender: AnyObject) {
        if self.mainWindow.alphaValue == 1.0 {
            
            NSAnimationContext.runAnimationGroup({
                (context) -> Void in
                context.duration = 0.3
                self.mainWindow.animator().alphaValue = 0.9
                }, completionHandler: { () -> Void in
                    self.NoteTextView.setNeedsDisplayInRect(self.NoteTextView.visibleRect)
            })
            
        }else{
            NSAnimationContext.runAnimationGroup({
                (context) -> Void in
                context.duration = 0.3
                self.mainWindow.animator().alphaValue = 1.0
                }, completionHandler: { () -> Void in
            })
        }
    }
    
    //Display styles popover
    @IBAction func stylesButtonPressed(sender: NSButton) {
        let positioningView = sender
        let positioningRect = NSZeroRect
        let preferredEdge = NSRectEdge.MaxY
        self.StylesPopover.showRelativeToRect(positioningRect, ofView: positioningView, preferredEdge: preferredEdge)

    }
    
    //Toggle darkmode
    @IBAction func darkmodeButtonPressed(sender: AnyObject) {
        self.mainWindow.toggleDarkMode()
    }
    
    //Distraction free mode
    func toggleToolbarVisibility(visible:Bool){
        
        if !visible && self.ToolbarView.alphaValue == 1 {
            NSAnimationContext.runAnimationGroup({
                (context) -> Void in
                context.duration = 1
                self.ToolbarView.animator().alphaValue = 0
                }, completionHandler: { () -> Void in
                self.ToolbarView.hidden = true
            })
        }
        if visible && self.ToolbarView.hidden {
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                self.ToolbarView.hidden = false
                context.duration = 1
                self.ToolbarView.animator().alphaValue = 1
                }, completionHandler: { () -> Void in
            })
        }
    }

    //Select new note from list
    @IBAction func noteTablePressed(sender: NSTableView) {
        if let cNote = self.getCurrentNote() {
        self.setNoteTitleLabel((cNote.filepath)!, appIcon: cNote.appicon!)
        }
    }

    
    //Trackingarea for distraction free mode
    func updateTrackingArea(){
        if self.TitleBarTrackingView.trackingAreas.first?.rect.width < self.TitleBarTrackingView.bounds.width{
        let trackingArea = NSTrackingArea(rect: self.TitleBarTrackingView.bounds,
            options: [.ActiveAlways, .MouseEnteredAndExited],
            owner: self, userInfo: nil)
        self.TitleBarTrackingView.addTrackingArea(trackingArea)
        }
    }
    
    
    //TODO: Make this work for dark mode
//    func makeWhiteIBeamCursor(){
//        
//        
//        let defaultIBeamCursorTiff = NSCursor.IBeamCursor().image.TIFFRepresentation
//        let filter = CIFilter(name: "CIColorInvert")
//        filter?.setValue(defaultIBeamCursorTiff, forKey: "inputImage")
//        let outputImage = filter?.outputImage
//        let rep = NSCIImageRep(CIImage: outputImage!)
//        let newIBeamCursorImage = NSImage(size: rep.size)
//        newIBeamCursorImage.addRepresentation(rep)
//        
//        let newCursor = NSCursor(image: newIBeamCursorImage, hotSpot: NSCursor.IBeamCursor().hotSpot)
//        self.NoteTextView.addCursorRect(self.NoteTextView.visibleRect, cursor: newCursor)
//        
//    }
    
    
    //Handle toolbar actions
    
    @IBAction func insertCheckmarkButtonPressed(sender: AnyObject) {
        self.NoteTextView.insertCheckMark()
    }
    
    @IBAction func SettingsButtonPressed(sender: AnyObject) {
        
        self.SettingsMenu.popUpMenuPositioningItem(nil, atLocation:NSEvent.mouseLocation() , inView: sender.view)
    }
    
    @IBAction func QuitButtonPressed(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func setBoldButtonPressed(sender: AnyObject) {
        if (self.NoteTextView.shouldChangeTextInRange(self.NoteTextView.selectedRange(), replacementString:nil))
        {
        self.NoteTextView.textStorage?.beginEditing()
        //        textView.textStorage?.replaceCharactersInRange(affectedCharRange, withString: replacementString!)
         self.NoteTextView.textStorage?.applyFontTraits(NSFontTraitMask.BoldFontMask, range: self.NoteTextView.selectedRange())
        let fontManager = NSFontManager.sharedFontManager()
        let newfont = fontManager.convertFont(self.NoteTextView.font!, toHaveTrait: NSFontTraitMask.BoldFontMask)
        self.NoteTextView.typingAttributes[NSFontAttributeName] = newfont
        self.NoteTextView.textStorage?.endEditing()
        self.NoteTextView.didChangeText()
        }
    }
    
    @IBAction func setItalicButtonPressed(sender: NSButton) {
        if (self.NoteTextView.shouldChangeTextInRange(self.NoteTextView.selectedRange(), replacementString:nil))
        {
            self.NoteTextView.textStorage?.beginEditing()
            self.NoteTextView.textStorage?.applyFontTraits(NSFontTraitMask.ItalicFontMask, range: self.NoteTextView.selectedRange())
            let fontManager = NSFontManager.sharedFontManager()
            let newfont = fontManager.convertFont(self.NoteTextView.font!, toHaveTrait: NSFontTraitMask.ItalicFontMask)
            self.NoteTextView.typingAttributes[NSFontAttributeName] = newfont
            self.NoteTextView.textStorage?.endEditing()
            self.NoteTextView.didChangeText()
        }
    }
    
    override func awakeFromNib() {
        self.NoteListTableView.sortDescriptors =  [NSSortDescriptor(key: "edittime", ascending: false, selector: Selector("compare:"))]
        let trackingArea = NSTrackingArea(rect: self.TitleBarTrackingView.bounds,
            options: [.ActiveAlways, .MouseEnteredAndExited],
            owner: self, userInfo: nil)
        self.TitleBarTrackingView.addTrackingArea(trackingArea)
    }
    
    
    override func mouseEntered(theEvent: NSEvent) {
       self.toggleToolbarVisibility(true)
    }
    
    func resetSearchField(){
        self.SearchFieldCell.stringValue=""
    }
    
    //Display currently selected note title
    func setNoteTitleLabel(noteRef:String, appIcon:NSImage) {
        let img = appIcon
        img.size = NSSize(width: 20, height: 20)
        let attachmentCell = NSTextAttachmentCell(imageCell: img)
        let attachment = NSTextAttachment()
        attachment.attachmentCell = attachmentCell
        
        let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        attributedString.addAttribute(NSBaselineOffsetAttributeName, value: -12, range: NSRange(location: 0,length: attributedString.length))
        
        attributedString.appendAttributedString(NSAttributedString(string: " " + noteRef, attributes: [NSBaselineOffsetAttributeName:-5]))
        
        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 26
        para.maximumLineHeight = 26
        para.lineSpacing = 0
        para.alignment = NSTextAlignment.Center
        para.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle;
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: para, range: NSRange(location: 0,length: attributedString.length))
        
        self.currentReferenceTitle.attributedStringValue = attributedString
    }
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return (NSApplication.sharedApplication().delegate
            as? AppDelegate)?.managedObjectContext }()!
    
    func tableViewSelectionIsChanging(notification: NSNotification) {
        self.UserChangesTableSelection = true
        self.ApplicationDelegate.deleteEmptyNote()
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if !self.UserChangesTableSelection {
        self.mainWindow.makeFirstResponder(self.NoteTextView)
        }
         self.UserChangesTableSelection = false
    }
}