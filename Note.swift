//
//  Note.swift
//  SmartNote
//
//  Created by Martin on 22.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation
import CoreData

class Note: NSManagedObject {

 //Insert code here to add functionality to your managed object subclass
    override func didChangeValueForKey(key: String) {
        if key == "content" {
            self.setValue(NSDate(), forKey: "edittime")
            if let moc = self.managedObjectContext{
            moc.processPendingChanges()
                //Swift.print("dfdsf")
            }
            //NSApp.delegate.note
        }
    }
}
