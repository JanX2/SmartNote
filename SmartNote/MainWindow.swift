//
//  MainWindow.swift
//  SmartNote
//
//  Created by Martin on 07.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation
import AppKit

let minReferenceListViewWidth:CGFloat = 150

//Custom window class with splitview and custom styling
class SmartNoteMainWindow: NSWindow, NSWindowDelegate, NSSplitViewDelegate
{
    private var masterViewWrapper:NSVisualEffectView!
    private var detailViewWrapper:NSView!
    private var attachmentsViewWrapper:NSView!
    
    private var isAttachmentsViewHidden = true
    private var isReferenceViewHidden = true
    private var isAnimating = false
    
    private var lastReferencelistPosition = CGFloat(minReferenceListViewWidth)
    
    @IBInspectable var splitView:NSSplitView!
    
    @IBInspectable var detailViewBackgroundColor:NSColor!
    @IBInspectable var minimumMasterViewWidth:CGFloat!
    @IBInspectable var maximumMasterViewWidth:CGFloat!
    @IBInspectable var initalMasterViewWidth:CGFloat!
    @IBOutlet weak var masterView: NSView!
    @IBOutlet weak var detailView: NSView!
    @IBOutlet weak var attachmentsView: NSView!
    @IBOutlet weak var referenceListViewContainer: NSView!
    @IBOutlet weak var preferencesWindow: NSWindow!
    @IBOutlet weak var constraintRight: NSLayoutConstraint!
    @IBOutlet weak var mainViewController: MainViewController!
    
    @IBOutlet var noteTextView: NSTextView!
    
    override init(contentRect: NSRect,
        styleMask windowStyle: Int,
        backing bufferingType: NSBackingStoreType,
        `defer` deferCreation: Bool)
    {
        super.init(contentRect: contentRect, styleMask: windowStyle, backing: bufferingType, `defer`: deferCreation)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(contentRect: NSRect,
        styleMask windowStyle: Int,
        backing bufferingType: NSBackingStoreType,
        `defer` deferCreation: Bool,
        screen: NSScreen?)
    {
        self.init(contentRect: contentRect, styleMask: windowStyle, backing: bufferingType, `defer`: deferCreation, screen: screen)
    }
    
    override func awakeFromNib() {
        self.setup()
        self.setMasterView(self.masterView)
        self.setDetailView(self.detailView)
        self.setAttachmensView(self.attachmentsView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidResignMain:", name: NSWindowDidResignMainNotification, object: self)
    }
    
    func setup()
    {
        self.titleVisibility = NSWindowTitleVisibility.Hidden
        self.titlebarAppearsTransparent = true
        self.styleMask |= NSFullSizeContentViewWindowMask
        self.standardWindowButton(NSWindowButton.CloseButton)?.hidden=true
        self.standardWindowButton(NSWindowButton.MiniaturizeButton)?.hidden=true
        self.standardWindowButton(NSWindowButton.FullScreenButton)?.hidden=true
        self.standardWindowButton(NSWindowButton.ZoomButton)?.hidden=true
        self.backgroundColor = NSColor(white: 0.99, alpha: 1.0)
        self.level =  Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
        self.splitView =  NSSplitView(frame: NSMakeRect(0, 0, NSWidth(self.frame), NSHeight(self.frame)))
        self.splitView.vertical = true
        self.masterViewWrapper = NSVisualEffectView(frame: NSMakeRect(0, 0, 161, NSHeight(self.frame)))
        self.masterViewWrapper.material = NSVisualEffectMaterial.Light
        self.detailViewWrapper = NSView(frame: NSMakeRect(0, 0, NSWidth(self.frame)-161, NSHeight(self.frame)))
        self.detailViewWrapper.wantsLayer = true
        
        //TODO: Implement attachments view
        self.attachmentsViewWrapper = NSView(frame: NSMakeRect(0, 0, 300, NSHeight(self.frame)))
        self.attachmentsViewWrapper.wantsLayer = true
        
        self.splitView.addSubview(self.detailViewWrapper)
        //self.splitView.addSubview(self.attachmentsViewWrapper)
        
        self.splitView.dividerStyle = NSSplitViewDividerStyle.Thin
        self.splitView.delegate = self
        self.splitView.adjustSubviews()
        self.splitView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        self.contentView!.addSubview(self.splitView)
        self.minimumMasterViewWidth = 161
        self.maximumMasterViewWidth = 1000
    }
    
    func toggleDarkMode(){
        self.backgroundColor = NSColor(white: 0.2, alpha: 1.0)
        self.noteTextView.textColor = NSColor(white: 0.98, alpha: 1.0)
        self.noteTextView.insertionPointColor = NSColor(white: 0.98, alpha: 1.0)
        self.noteTextView.selectedTextAttributes = [NSBackgroundColorAttributeName:NSColor(white: 0.3, alpha: 1)]
        self.masterViewWrapper.material = NSVisualEffectMaterial.Dark
    }
    
    
    func setInitialMasterViewWidth(initialMasterViewWidth:CGFloat)
    {
        self.initalMasterViewWidth = initialMasterViewWidth
    }
    
    
    override func restoreStateWithCoder(coder: NSCoder) {
        super.restoreStateWithCoder(coder)
        self.setNeedsLayout()
    }
    
    func windowDidResize(notification: NSNotification) {
        self.setNeedsLayout()
    }
    
    private func setMasterView(view:NSView)
    {
        view.removeFromSuperview()
        view.frame = self.masterViewWrapper.bounds
        view.autoresizingMask = [NSAutoresizingMaskOptions.ViewHeightSizable, NSAutoresizingMaskOptions.ViewWidthSizable]
        if ((self.masterView) != nil){
            self.masterView.removeFromSuperview()
        }
        self.masterView = view
        self.masterViewWrapper.addSubview(self.masterView)
    }
    
    private func setDetailView(view:NSView)
    {
        view.removeFromSuperview()
        view.frame = self.detailViewWrapper.bounds
        view.autoresizingMask = [NSAutoresizingMaskOptions.ViewHeightSizable, NSAutoresizingMaskOptions.ViewWidthSizable]
        if ((self.detailView) != nil){
            self.detailView.removeFromSuperview()
        }
        self.detailView = view
        self.detailViewWrapper.addSubview(self.detailView)
    }
    
    //TODO: Implement attachments view
    private func setAttachmensView(view:NSView)
    {
        view.removeFromSuperview()
        view.frame = self.attachmentsViewWrapper.bounds
        view.autoresizingMask = [NSAutoresizingMaskOptions.ViewHeightSizable]
        if ((self.attachmentsView) != nil){
            self.attachmentsView.removeFromSuperview()
        }
        self.attachmentsView = view
        self.attachmentsViewWrapper.addSubview(self.attachmentsView)
    }
    
    func setMasterViewWidth(masterViewWidth:CGFloat){
        self.splitView.setPosition(masterViewWidth, ofDividerAtIndex: 0)
    }
    
    func setNeedsLayout()
    {
        var tmpRect:NSRect = self.splitView.bounds
        let subviews:NSArray = self.splitView.subviews
        let collectionsSide:NSView = subviews.objectAtIndex(0) as! NSView
        let tableSide:NSView = subviews.objectAtIndex(1) as! NSView
        let collectionWidth = collectionsSide.bounds.size.width
        
        tmpRect.size.width = tmpRect.size.width - collectionWidth+1
        tmpRect.origin.x = tmpRect.origin.x + collectionWidth + 1
        
        tableSide.frame = tmpRect
        tmpRect.size.width = collectionWidth
        tmpRect.origin.x = 0
        collectionsSide.frame = tmpRect
    }
    
    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        self.mainViewController.updateTrackingArea()
        if (frameSize.width<300 && frameSize.height>=200) {
            return NSSize(width: 300, height: frameSize.height)
        }else if (frameSize.width>=300 && frameSize.height<200) {
            return NSSize(width: frameSize.width, height: 200)
        }else if (frameSize.width<300 && frameSize.height<200) {
            return NSSize(width: 300, height: 200)
        }else{
            return frameSize
        }
    }
    
    func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if self.isAnimating {
            return 0.0
        }
        return max(proposedMinimumPosition,minReferenceListViewWidth)
    }
    
    func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if self.isAnimating {
            return min(proposedMaximumPosition,self.frame.width-minReferenceListViewWidth,400)
        }
        return min(proposedMaximumPosition,self.frame.width-minReferenceListViewWidth,400)
    }
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        if(splitView==self.splitView && subview == self.masterViewWrapper)
        {
            return true
        } else if(splitView==self.splitView && subview == self.attachmentsViewWrapper)
        {
            return true
        }
        return false
    }
    
    func splitView(splitView: NSSplitView, shouldCollapseSubview subview: NSView, forDoubleClickOnDividerAtIndex dividerIndex: Int) -> Bool {
        if(splitView==self.splitView && subview == self.masterViewWrapper)
        {
            return true
        } else if(splitView==self.splitView && subview == self.attachmentsViewWrapper)
        {
            return true
        }
        return false
    }
    
    
    func splitView(splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        if self.isAnimating {
            return false
        }
        if(view==self.masterViewWrapper){
            self.constraintRight.constant = view.bounds.width
            if(view.bounds.width<=minReferenceListViewWidth)
            {
                return false
            }
        }
        return true
    }
    
    
    @IBAction func AnimateReferenceList(sender: AnyObject) {
        self.isAnimating = true
        
        if(self.isReferenceViewHidden)
        {
            
            self.splitView.addSubview(self.masterViewWrapper, positioned: NSWindowOrderingMode.Below, relativeTo: nil)
            self.constraintRight.constant = min(lastReferencelistPosition,self.frame.width-minReferenceListViewWidth)
            
            _ = SplitViewAnimation.init(splitView: self.splitView, dividerIndex: 0, startPosition: 0.0, endPosition: lastReferencelistPosition, completionBlock: { () -> Void in
                
                self.isReferenceViewHidden = !self.isReferenceViewHidden
                self.isAnimating = false
                
            }).startAnimation()
        }else{
            self.lastReferencelistPosition = self.masterView.frame.width
            _ = SplitViewAnimation.init(splitView: self.splitView, dividerIndex: 0, startPosition: lastReferencelistPosition, endPosition: 0.0, completionBlock: { () -> Void in
                self.splitView.removeArrangedSubview(self.masterViewWrapper)
                self.isReferenceViewHidden = !self.isReferenceViewHidden
                self.isAnimating = false
                
            }).startAnimation()
        }
    }
    
    @IBAction func preferencesButtonPressed(sender: NSMenuItem) {
        if(!self.preferencesWindow.visible)
        {
            self.preferencesWindow.setIsVisible(true)
        }else{
            self.preferencesWindow.setIsVisible(false)
        }
        
    }
    
    //Todo: Implement attachment view...
    @IBAction func attachmentssButtonPressed(sender: AnyObject) {
        var dividerIndex = 0
        self.isAnimating = true
        
        if(!self.isReferenceViewHidden)
        {
            dividerIndex = 1
        }
        
        if self.isAttachmentsViewHidden {
            self.splitView.addArrangedSubview(self.attachmentsViewWrapper)
            self.attachmentsViewWrapper.setFrameSize(NSSize(width: 0, height: self.frame.height))
            self.isAnimating = true
            _ = SplitViewAnimation.init(splitView: self.splitView, dividerIndex: dividerIndex, startPosition: self.frame.width, endPosition: self.frame.width-200, completionBlock: { () -> Void in
                self.isAnimating = false
                
            }).startAnimation()
        }else{
            self.splitView.addArrangedSubview(self.attachmentsViewWrapper)
            self.attachmentsViewWrapper.setFrameSize(NSSize(width: 0, height: self.frame.height))
            _ = SplitViewAnimation.init(splitView: self.splitView, dividerIndex: dividerIndex, startPosition: self.frame.width-200, endPosition: self.frame.width, completionBlock: { () -> Void in
                self.isAnimating = false
                self.splitView.removeArrangedSubview(self.attachmentsViewWrapper)
            }).startAnimation()
        }
        
        self.isAttachmentsViewHidden = !self.isAttachmentsViewHidden
    }
    
    //Necessary method
    func windowDidResignMain(notification: NSNotification) {
        
    }
    
}