//
//  Note+CoreDataProperties.swift
//  SmartNote
//
//  Created by Martin on 22.10.15.
//  Copyright © 2015 Martin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Note {

    @NSManaged var appname: String?
    @NSManaged var content: NSObject?
    @NSManaged var title: String?
    @NSManaged var urlbookmark: NSData?
    @NSManaged var urlreference: String?
    @NSManaged var appicon: NSImage?
}
