//
//  WindowEvent.swift
//  SmartNote
//
//  Created by Martin on 01.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//


import Cocoa
import Carbon

class WindowEvent {
    private let windowEvent: EventTargetRef
    private let eventHandler: EventHandlerRef
    private var registered = true
    
    private init(windowEvent: EventTargetRef, eventHandler: EventHandlerRef) {
        self.windowEvent = windowEvent
        self.eventHandler = eventHandler
    }
    
    static func register(block: () -> ()) -> WindowEvent? {
        let windowEvent: EventTargetRef = nil
        var eventHandler: EventHandlerRef = nil
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassApplication), eventKind: UInt32(kEventAppFrontSwitched))
        
        let ptr = UnsafeMutablePointer<() -> ()>.alloc(1)
        ptr.initialize(block)
        
        guard InstallEventHandler(GetApplicationEventTarget(), {(_: EventHandlerCallRef, _: EventRef, ptr: UnsafeMutablePointer<Void>) -> OSStatus in
            UnsafeMutablePointer<() -> ()>(ptr).memory()
            return noErr
            }, 1, &eventType, ptr, &eventHandler) == noErr else {return nil}
        return WindowEvent(windowEvent: windowEvent, eventHandler: eventHandler)
    }
    
    func unregister() {
        //guard registered else {return}
        RemoveEventHandler(self.eventHandler)
        registered = false
    }
}