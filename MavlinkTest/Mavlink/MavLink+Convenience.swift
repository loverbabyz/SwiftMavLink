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

    init?(hexString:String, skipCRC:Bool = false) {
        let d = try! NSData(hexString: hexString)
        let buffer:UnsafeBufferPointer <UInt8> = d.buffer.toUnsafeBufferPointer()
        self.init(buffer:buffer, skipCRC:skipCRC)
    }

    init?(url:NSURL, skipCRC:Bool = false) {
        if let data = NSData(contentsOfURL: url) {
        let buffer:UnsafeBufferPointer <UInt8> = data.buffer.toUnsafeBufferPointer()
            self.init(buffer:buffer, skipCRC:skipCRC)
        }
        else {
            return nil
        }
    }
}

