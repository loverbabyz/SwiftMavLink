//
//  Message+Convenience.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 3/31/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

import SwiftUtilities

extension Message {
    init(hexString:String, skipCRC:Bool = false) throws {
        let d = try NSData.decodeFromString(hexString, base: 16)
        let buffer = UnsafeBufferPointer <Void> (start: d.bytes, count: d.length)
        try self.init(buffer:buffer, skipCRC:skipCRC)
    }
}

