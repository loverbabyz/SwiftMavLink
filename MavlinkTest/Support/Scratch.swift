//
//  Scratch.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 7/7/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation
import CoreData

import SwiftUtilities

func loadCD() throws -> (NSPersistentStoreCoordinator) {

    let modelURL = NSBundle.mainBundle().URLForResource("MavlinkLog", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOfURL: modelURL)!
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    var storeURL = try! NSFileManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    storeURL = storeURL + "MavlinkLogView"

    try NSFileManager().createDirectoryAtURL(storeURL, withIntermediateDirectories: true, attributes: nil)
    storeURL = storeURL + "/MavlinkLog.sqlite"
    print(storeURL)

    try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)


    return coordinator
}
