//
//  Message+Convenience.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 3/31/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

extension Message {

    init?(hexString:String, skipCRC:Bool = false) {
        let d = NSData(hexString: hexString)
        let buffer:UnsafeBufferPointer <UInt8> = d!.buffer.asUnsafeBufferPointer()
        self.init(buffer:buffer, skipCRC:skipCRC)
    }

    init?(url:NSURL, skipCRC:Bool = false) {
        if let data = NSData(contentsOfURL: url) {
            let buffer:UnsafeBufferPointer <UInt8> = data.buffer.asUnsafeBufferPointer()
            self.init(buffer:buffer, skipCRC:skipCRC)
        }
        else {
            return nil
        }
    }
}

