//
//  MavlinkScanner.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 4/22/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import SwiftUtilities

public extension DataScanner {
    func scan() throws -> Message? {
        let message = try Message(buffer: remaining, skipCRC:true)
        current += message.length
        return message
    }
}

public extension Message {

    static func messagesFromBuffer(buffer:UnsafeBufferPointer <Void>) throws -> [Message] {
        var messages:[Message] = []
        let scanner = DataScanner(buffer: buffer)
        while scanner.atEnd == false {
            if let _ = try scanner.scanUpTo(0xFE) {
        //        print("Skipping: \(junk.asHex)")
            }
            guard let message:Message = try scanner.scan() else {
                break
            }
            messages.append(message)
        }
        return messages
    }


}