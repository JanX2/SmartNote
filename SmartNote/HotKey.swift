//
//  HotKey.swift
//  SmartNote
//
//  Created by Martin on 01.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Cocoa
import Carbon

class HotKey {
    private let hotKey: EventHotKeyRef
    private let eventHandler: EventHandlerRef
    private var registered = true
    
    private init(hotKey: EventHotKeyRef, eventHandler: EventHandlerRef) {
        self.hotKey = hotKey
        self.eventHandler = eventHandler
    }
    
    static func register(keyCode: UInt32, modifiers: UInt32, block: () -> ()) -> HotKey? {
        var hotKey: EventHotKeyRef = nil
        var eventHandler: EventHandlerRef = nil
        let hotKeyID = EventHotKeyID(signature: 1, id: 1)
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let ptr = UnsafeMutablePointer<() -> ()>.alloc(1)
        ptr.initialize(block)
        
        guard InstallEventHandler(GetApplicationEventTarget(), {(_: EventHandlerCallRef, _: EventRef, ptr: UnsafeMutablePointer<Void>) -> OSStatus in
            UnsafeMutablePointer<() -> ()>(ptr).memory()
            return noErr
            }, 1, &eventType, ptr, &eventHandler) == noErr &&
            RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), OptionBits(0), &hotKey) == noErr else {return nil}
        return HotKey(hotKey: hotKey, eventHandler: eventHandler)
    }
    
    func unregister() {
        guard registered else {return}
        UnregisterEventHotKey(hotKey)
        RemoveEventHandler(eventHandler)
        registered = false
    }
}