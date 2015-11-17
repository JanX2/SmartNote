//
//  AXHelper.swift
//  SmartNote
//
//  Created by Martin on 05.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import AppKit
import ScriptingBridge

class NoteReference:NSObject{
    private let appName:String
    private let fileReference:String
    private let filePath:String
    private let appIcon:NSImage
    
    init(appName:String,appIcon:NSImage, filePath:String)
    {
        self.appName = appName
        self.appIcon = appIcon
        
        if filePath != "" && filePath.hasPrefix("file:///") {
            if let fileUrl = NSURL(string: filePath) {
                if let fileP = fileUrl.path{
                    self.filePath = fileP
                }else{
                    self.filePath = filePath
                }
                if let fileRefUrl = fileUrl.fileReferenceURL() {
                    self.fileReference = fileRefUrl.absoluteString
                }else{
                    self.fileReference = filePath
                }
                
            }else{
                self.filePath = filePath
                self.fileReference = filePath
            }
        }else{
            self.filePath = filePath
            self.fileReference = filePath
        }
        
        super.init()
    }
    
    internal func getAppName()->String{
        return self.appName
    }
    
    internal func getAppIcon()->NSImage{
        return self.appIcon
    }
    
    internal func getFileReference()->String{
        return self.fileReference
    }
    
    internal func getFilePath()->String{
        return self.filePath
    }
    
}

class AXHelper {
    static func findDocURL(appRef:AXUIElement)->NSString{
        
        let documentAttribute: UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        
        let focusedWindowRef: UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        
        if(AXUIElementCopyAttributeValue(appRef, NSAccessibilityFocusedWindowAttribute, focusedWindowRef)==AXError.Success)
        {
            let error = AXUIElementCopyAttributeValue(focusedWindowRef.memory as! AXUIElement, NSAccessibilityDocumentAttribute, documentAttribute)
            if(error == AXError.Success)
            {
                return documentAttribute.memory as! NSString
            }else
            {
                //dump(error.rawValue)
            }
        }
        return ""
    }
    
    
    static func applicationPathFromName(appName : String) -> String
    {
        let workspace = NSWorkspace.sharedWorkspace()
        if let appPath = workspace.fullPathForApplication(appName){
            return appPath
        }
        return ""
    }
    
    static func currentAppPath()->String{
        if let frontMostApp = NSWorkspace.sharedWorkspace().frontmostApplication{
            return (frontMostApp.bundleURL?.relativePath)!
        }else{
            return ""
        }
    }
    
    static func iconURLForApplicationBundleIdentifier(bundleIdentifier:String)->NSImage{
        
        return NSWorkspace.sharedWorkspace().iconForFile(bundleIdentifier)
    }
    
    
    static func getAttributeInPath(appRef:AXUIElement, axPath:NSArray, attribute:String )->String{
        
        let value: UnsafeMutablePointer<AnyObject?>=UnsafeMutablePointer<AnyObject?>.alloc(1)
        let focusedWindowRef: UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        
        
        if(AXUIElementCopyAttributeValue(appRef, NSAccessibilityFocusedWindowAttribute, focusedWindowRef)==AXError.Success)
        {
            let axElements = self.findDescentantsOf(focusedWindowRef.memory as! AXUIElement, matchingRolePath:axPath)
            if axElements.count == 1 {
                let axElement = axElements.objectAtIndex(0)
                let error = AXUIElementCopyAttributeValue(axElement as! AXUIElement, attribute, value)
                if(error == AXError.Success)
                {
                    if let url = value.memory as? NSURL {
                        return url.absoluteString
                    }else if let attribute = value.memory as? NSString {
                        return attribute as String
                    }else{
                        return ""
                    }
                }
            }
        }
        return ""
    }
    
    static func getFinderFileURL()->String {
        let f: FinderApplication = SBApplication(bundleIdentifier:"com.apple.finder") as! FinderApplication
        
        let selectedFiles = f.selection!.get()
        if selectedFiles!.count == 1 {
            let f = selectedFiles?.objectAtIndex(0) as! FinderFile
            if (f.URL != nil) {
                let url=NSURL(string: f.URL!)
                return (url?.filePathURL?.absoluteString)!
            }else{
                return ""
            }
        }
        return ""
    }
    
    static func findDescentantsOf(top:AXUIElementRef, matchingRolePath:NSArray)->NSArray
    {
        var elem:AXUIElementRef
        let value:UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        let result:NSMutableArray = NSMutableArray()
        
        if(matchingRolePath.count>=1){
            let role = matchingRolePath.objectAtIndex(0)
            if(AXUIElementCopyAttributeValue(top, NSAccessibilityChildrenAttribute, value)==AXError.Success){
                if let children = value.memory as? NSArray {
                    for obj in children
                    {
                        elem = obj as! AXUIElementRef
                        if(AXUIElementCopyAttributeValue(elem, NSAccessibilityRoleAttribute, value)==AXError.Success){
                            if(value != nil && role.isEqual(value.memory as! String)){
                                if(matchingRolePath.count==1){
                                    result.addObject(obj)
                                }else{
                                    let subPath = NSMutableArray(array: matchingRolePath)
                                    subPath.removeObjectAtIndex(0)
                                    let subResult = self.findDescentantsOf(elem, matchingRolePath: subPath)
                                    for x in subResult{
                                        result.addObject(x)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    
    static func retrieveNoteReference()->NoteReference?{
        
        let SAFARI_AX_PATH =  NSArray.init(objects: "AXSplitGroup", "AXTabGroup", "AXGroup", "AXGroup", "AXScrollArea", "AXWebArea")
        let CHROME_AX_PATH =  NSArray.init(objects: "AXToolbar","AXTextField")
        
        let appRef: UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        let appTitle: UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        let systemwideElement=AXUIElementCreateSystemWide().takeUnretainedValue()
        
        var filePath:NSString = ""
        
        let error = AXUIElementCopyAttributeValue(systemwideElement, kAXFocusedApplicationAttribute, appRef)
        
        if(error == AXError.Success)
        {
            if(appRef != nil){
                if(AXUIElementCopyAttributeValue(appRef.memory as! AXUIElementRef, NSAccessibilityTitleAttribute, appTitle)==AXError.Success)
                {
                    switch appTitle.memory as! String{
                    case "Finder":
                        filePath = self.getFinderFileURL()
                        break
                    case "Xcode":
                        filePath = self.findDocURL(appRef.memory as! AXUIElement)
                        break
                    case "Safari":
                        filePath = self.getAttributeInPath(appRef.memory as! AXUIElement, axPath: SAFARI_AX_PATH, attribute: NSAccessibilityURLAttribute)
                        break
                    case "Chrome":
                        filePath = self.getAttributeInPath(appRef.memory as! AXUIElement, axPath: CHROME_AX_PATH, attribute: NSAccessibilityValueAttribute)
                        break
                    default:
                        filePath = self.findDocURL(appRef.memory as! AXUIElement)
                    }
                    
                    if(filePath != "")
                    {
                        return NoteReference(appName: appTitle.memory as! String, appIcon: iconURLForApplicationBundleIdentifier(currentAppPath()), filePath: filePath as String)
                    }else{
                        return NoteReference(appName: appTitle.memory as! String, appIcon: iconURLForApplicationBundleIdentifier(currentAppPath()), filePath: appTitle.memory as! String)
                    }
                }
            }
        }
        return nil
    }
}