//
//  AppDelegate.swift
//  SmartNote
//
//  Created by Martin on 06.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Cocoa
import Carbon

let MASObservingContext:UnsafeMutablePointer<Void> = UnsafeMutablePointer<Void>.alloc(1)

let DistractionFreeMode = false //TODO: Implement fully

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    @IBOutlet weak var noteArrayController: NSArrayController!
    @IBOutlet weak var mainViewController: MainViewController!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var noteClipView: NSClipView!
    @IBOutlet var noteTextView: CustomTextView!
    @IBOutlet weak var NoteTableView: NSTableView!
    @IBOutlet weak var ShortCutView: MASShortcutView!
    @IBOutlet weak var titlebarView: NSView!
    
    @IBOutlet weak var liveupdateNoteViewCheckbox: NSButtonCell!
    
    
    private var mouseEventMonitor:AnyObject?
    private var windowEvent:WindowEvent?
    
    private var icon: IconView
    var lastRef:String=""

    override init(){
        let bar = NSStatusBar.systemStatusBar();
        let length: CGFloat = -1 //NSVariableStatusItemLength
        let item = bar.statusItemWithLength(length);
        self.icon = IconView(imageName: "icon", item: item);
        item.view = icon;
    }
    
    override func awakeFromNib() {
        self.loadUserDefaults()
        let icon = self.icon
        icon.onMouseDown = self.toggleMainWindowVisibility
        
    }
    
    func toggleMainWindowVisibility(){
        
        if(!self.window.visible)
        {
            self.window.setIsVisible(true)
        }else{
            self.window.setIsVisible(false)
        }
        
        self.processNoteForEvent()
    }
    
    //Load settings on start
    func loadUserDefaults(){
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

        defaults.registerDefaults(["liveupdateNoteView":true,"hardcodedShortcutEnabled":true, "customShortcutEnabled":true])
        self.ShortCutView.associatedUserDefaultsKey = "customShortcut"
        self.ShortCutView.bind("enabled", toObject: defaults, withKeyPath: "hardcodedShortcutEnabled", options: [:])
        self.liveupdateNoteViewCheckbox.bind("value", toObject: defaults, withKeyPath: "liveupdateNoteView", options: [:])
        defaults.addObserver(self, forKeyPath: "liveupdateNoteView", options: [NSKeyValueObservingOptions.Initial,NSKeyValueObservingOptions.New], context: MASObservingContext)
        defaults.addObserver(self, forKeyPath: "customShortcutEnabled", options: [NSKeyValueObservingOptions.Initial,NSKeyValueObservingOptions.New], context: MASObservingContext)
        defaults.addObserver(self, forKeyPath: "hardcodedShortcutEnabled", options: [NSKeyValueObservingOptions.Initial,NSKeyValueObservingOptions.New], context: MASObservingContext)
    }
    
    
    func terminateApplication(){
        NSApplication.sharedApplication().terminate(self)
    }

    //Init event listeners
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        self.window.collectionBehavior = .CanJoinAllSpaces
        self.mainViewController.managedObjectContext = self.managedObjectContext
        
        if self.liveupdateNoteViewCheckbox.state == NSOnState {
        self.enableLiveupdateNoteView()
        }
    
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        self.noteClipView.postsBoundsChangedNotifications = true

        _ = notificationCenter.addObserver(self, selector: "boundDidChange:", name:NSViewBoundsDidChangeNotification, object: self.noteClipView)
        
        _ = notificationCenter.addObserverForName(NSTextStorageWillProcessEditingNotification, object: self.noteTextView.textStorage, queue: mainQueue){
            (n:NSNotification) in
            
            if DistractionFreeMode{
            self.mainViewController.toggleToolbarVisibility(false)
            }
        }
    }
    

    @IBAction func liveupdateNoteViewButtonPressed(sender: NSButton) {
        if sender.state == NSOnState{
            self.enableLiveupdateNoteView()
        }else{
            self.disableLiveupdateNoteView()
        }
    }
    
    func enableLiveupdateNoteView(){
            self.mouseEventMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask([.LeftMouseDownMask, .KeyUpMask]) {
                (event) -> Void in
                if(self.window.visible){
                    self.window.makeFirstResponder(self.noteTextView)
                    self.processNoteForEvent()
                }
            }!
        
            self.windowEvent = WindowEvent.register({
                self.processNoteForEvent()
            })
    }
    
    func disableLiveupdateNoteView(){
        if (self.mouseEventMonitor != nil) {
        NSEvent.removeMonitor(self.mouseEventMonitor!)
        }
        if (self.windowEvent != nil) {
        _ = WindowEvent.unregister(self.windowEvent!)
        }
    }

    
    func boundDidChange(notification:NSNotification){
        if DistractionFreeMode{
            self.mainViewController.toggleToolbarVisibility(false)
        }
    }
    
    //Event handling and information retrival
    func processNoteForEvent(){
        if self.liveupdateNoteViewCheckbox.state != NSOnState {return} //TODO: Remove this hack
            autoreleasepool {
                self.mainViewController.resetSearchField()
                self.noteArrayController.filterPredicate = nil
                if let noteRef = AXHelper.retrieveNoteReference(){
                    let currentAppName = noteRef.getAppName()
                    
                    if currentAppName != "SmartNote" {
                        if currentAppName != "" {
                        lastRef = noteRef.getFilePath()
                        }
                    }
                    
                    //Check if current window is not the app
                    if(currentAppName != "SmartNote") {
                        let curNote = self.mainViewController.getCurrentNote()
                        
                        if curNote?.filepath != lastRef {
                                self.deleteEmptyNote()
                            
                                let referencePredicate = NSPredicate(format: "filepath == %@", lastRef);
                                let object = self.noteArrayController.arrangedObjects.filteredArrayUsingPredicate(referencePredicate)
                                if object.count>0{
                                    
                                    if(object[0].valueForKey("content")?.count==0){
                                        self.managedObjectContext.deleteObject(object[0] as! NSManagedObject)
                                        let newNote = self.noteArrayController.newObject()
                                        newNote.setValue(lastRef, forKey: "title")
                                        newNote.setValue(noteRef.getFileReference(), forKey: "filepath")
                                        newNote.setValue("", forKey: "content")
                                        newNote.setValue(noteRef.getAppName(), forKey: "appname")
                                        newNote.setValue(noteRef.getAppIcon(),forKey:"appicon")
                                        newNote.setValue(noteRef.getFilePath(),forKey:"filepath")
                                        newNote.setValue(NSDate(),forKey:"edittime")
                                        
                                        self.managedObjectContext.processPendingChanges()
                                        self.noteArrayController.setSelectedObjects(NSArray(object: newNote) as [AnyObject])
                                        self.window.makeFirstResponder(self.noteTextView)
                                    }else{
                                        self.noteArrayController.setSelectedObjects(object)
                                            self.mainViewController.setNoteTitleLabel(noteRef.getFilePath(),appIcon: noteRef.getAppIcon())
                                        self.managedObjectContext.processPendingChanges()
                                    }
                                }else{
                                    let newNote = self.noteArrayController.newObject()
                                    newNote.setValue(lastRef, forKey: "title")
                                    newNote.setValue(noteRef.getFileReference(), forKey: "urlreference")
                                    newNote.setValue("", forKey: "content")
                                    newNote.setValue(noteRef.getAppName(), forKey: "appname")
                                    newNote.setValue(noteRef.getAppIcon(),forKey:"appicon")
                                    newNote.setValue(noteRef.getFilePath(),forKey:"filepath")
                                    newNote.setValue(NSDate(),forKey:"edittime")
                                    self.managedObjectContext.processPendingChanges()
                                    self.noteArrayController.setSelectedObjects(NSArray(object: newNote) as [AnyObject])
                                    self.mainViewController.setNoteTitleLabel(noteRef.getFilePath(),appIcon: noteRef.getAppIcon())
                                    self.noteTextView.setStandardParagraphStyle()
                                    self.window.makeFirstResponder(self.noteTextView)
                            }
                        }
                    }
                }
            }
        self.managedObjectContext.processPendingChanges()
    }
    
    func refreshManagedObjectContext(){
        self.managedObjectContext.processPendingChanges()
    }
    
    func deleteEmptyNote(){
        if(self.noteTextView.string==""){
            if let curNote = self.mainViewController.getCurrentNote() {
                self.managedObjectContext.deleteObject(curNote)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != MASObservingContext{
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if let newValue:Bool = change![NSKeyValueChangeNewKey]?.boolValue {
            if keyPath == "customShortcutEnabled" {
                self.setCustomShortcutEnabled(newValue)
            } else if keyPath == "hardcodedShortcutEnabled" {
                self.setHardcodedShortcutEnabled(newValue)
            }
        }
        
    }
    
    func setCustomShortcutEnabled(enabled:Bool){
        if enabled {
            MASShortcutBinder.sharedBinder().bindShortcutWithDefaultsKey("customShortcut", toAction: self.shortCutFunction)
        }else{
            MASShortcutBinder.sharedBinder().breakBindingWithDefaultsKey("customShortcut")
        }
    }
    
    
    func setHardcodedShortcutEnabled(enabled:Bool){
        
        let shortCut:MASShortcut = MASShortcut(keyCode: UInt(kVK_ANSI_H), modifierFlags: NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ControlKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue)
        if enabled {
            
            MASShortcutMonitor.sharedMonitor().registerShortcut(shortCut, withAction: self.shortCutFunction)
        }else{
            MASShortcutMonitor.sharedMonitor().unregisterShortcut(shortCut)
        }
    }
    
    
    func shortCutFunction(){
        if(!self.window.visible)
        { self.window.setIsVisible(true)
        }else{
            self.window.setIsVisible(false)
        }
        self.processNoteForEvent()
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    

    func applicationWillTerminate(aNotification: NSNotification) {
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "martin.SmartNote" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.URLByAppendingPathComponent("martin.SmartNote")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SmartNote", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = NSFileManager.defaultManager()
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        do {
            let properties = try self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey])
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch  {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CocoaAppCD.storedata")
            do {
                try coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil)
            } catch {
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            if failError != nil {
                dict[NSUnderlyingErrorKey] = failError
            }
            let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.sharedApplication().presentError(error)
            abort()
        } else {
            return coordinator!
        }
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(sender: AnyObject!) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSApplication.sharedApplication().presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }

    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        self.deleteEmptyNote()

        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
            return .TerminateCancel
        }
        
        if !managedObjectContext.hasChanges {
            return .TerminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .TerminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButtonWithTitle(quitButton)
            alert.addButtonWithTitle(cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                return .TerminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .TerminateNow
    }

}

