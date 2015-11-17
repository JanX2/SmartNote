//
//  PopoverViewController.swift
//  SmartNote
//
//  Created by Martin on 20.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation

class PopoverViewController:NSViewController, NSPopoverDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var StylesPopover: NSPopover!
    @IBOutlet var NoteTextView: CustomTextView!
    
    
    var tokenText: [String] = ["Title", "Heading", "Text","Listing","Enumeration"]
    let textStyles: NoteTextStyles = NoteTextStyles()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    // Popover methods
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
    }
    
    func popoverDidShow(notification: NSNotification) {
        //enableHideButton()
    }
    
    func popoverDidClose(notification: NSNotification) {
        let closeReason = notification.userInfo![NSPopoverCloseReasonKey] as! String
        if (closeReason == NSPopoverCloseReasonStandard) {
            //disableHideButton()
        }
    }
    
    //Style insertion
    @IBAction func stylePopupTablePressed(sender: NSTableView) {
        
        let index = (sender.selectedRow == -1 ? self.textStyles.styles.count-1 : sender.selectedRow)
        let style = self.textStyles.styles[index]
        let range = self.NoteTextView.selectedRange()
        
        if range.length>0{
            if (self.NoteTextView.shouldChangeTextInRange(self.NoteTextView.selectedRange(), replacementString:nil))
            {
                self.NoteTextView.textStorage?.beginEditing()
                self.NoteTextView.textStorage?.setAttributes([NSFontAttributeName:style.font, NSParagraphStyleAttributeName:style.paragraphStyle], range: self.NoteTextView.selectedRange())
                self.NoteTextView.textStorage?.endEditing()
                self.NoteTextView.didChangeText()
            }
        }else{
            self.NoteTextView.typingAttributes = [NSFontAttributeName:style.font,NSParagraphStyleAttributeName:style.paragraphStyle]
            
            //TODO: Implement more list types and switch case here
            if style.listType == 1 {
                //TODO: Better Tabstops and custom pboard write
                self.NoteTextView.textStorage?.beginEditing()
                let paragraph : NSMutableParagraphStyle = NSMutableParagraphStyle()
                paragraph.tabStops[0] = NSTextTab(type: .RightTabStopType , location: 25)
                paragraph.tabStops[1] = NSTextTab(type: .RightTabStopType, location: 26)
//              paragraph.tabStops[3] = NSTextTab(type: .RightTabStopType, location: 27.0)
                 let textList : NSTextList  = NSTextList(markerFormat: "{decimal}. ", options: 0)
                textList.listOptions
                 paragraph.paragraphSpacing = 5
                 paragraph.textLists = [textList]
                
                let attributedString = NSAttributedString(string: "\t" + textList.markerForItemNumber(1) + "\t", attributes: [NSParagraphStyleAttributeName:paragraph, NSFontAttributeName:self.NoteTextView.defaultFont])
                
                 self.NoteTextView.textStorage?.appendAttributedString(attributedString)
                 self.NoteTextView.textStorage?.endEditing()
            }
            
        }
        self.NoteTextView.setNeedsDisplayInRect(self.NoteTextView.visibleRect)
        self.StylesPopover.close()
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return self.textStyles.styles.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        view.textField!.stringValue = self.textStyles.styles[row].label
        view.textField!.font = self.textStyles.styles[row].font
        return view
    }
}