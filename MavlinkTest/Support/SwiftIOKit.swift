//
//  SwiftIOKit.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

class IOObject {

    let object:io_object_t

    init?(object:io_object_t) {
        self.object = object
        if object == 0 {
            return nil
        }
    }

    deinit {
        if object != 0 {
            IOObjectRelease(object)
        }
    }

    var className:String {
        get {
            return IOObjectCopyClass(object).takeRetainedValue() as String
        }
    }

    var bundleID:String {
        get {
            return IOObjectCopyBundleIdentifierForClass(className).takeRetainedValue() as String
        }
    }

    var properties:NSDictionary! {
        get {
            var properties:Unmanaged<CFMutableDictionary>?
            let result = IORegistryEntryCreateCFProperties(object, &properties, nil, IOOptionBits())
            if let properties = properties?.takeRetainedValue() where result == 0 {
                return properties
            }
            return nil
        }
    }
}