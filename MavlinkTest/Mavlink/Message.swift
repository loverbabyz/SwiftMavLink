//
//  MavLink.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

import SwiftUtilities

// MARK: -

public struct Message {
    public let sequence: UInt8
    public let systemID: UInt8
    public let componentID: UInt8
    public let messageID: UInt8
    public let body: DispatchData <Void>
    public let crc: UInt16
    public let definition: MessageDefinition?

    public var length: Int {
        return 6 + body.count + 2
    }

    public var header: DispatchData <Void> {
        let data = DispatchData <UInt8> ([ 0xFE, UInt8(body.length), sequence, systemID, componentID, messageID ])
        return data.toDispatchData()
    }

    public var footer: DispatchData <Void> {
        let data = DispatchData <UInt16> ([ crc ])
        return data.toDispatchData()
    }

    public var data: DispatchData <Void> {
        return header + body + footer
    }
}

// MARK: -

extension Message: CustomStringConvertible {
    public var description: String {
        var s = "Message(sequence:\(sequence), systemID:\(systemID), componentID:\(componentID), messageID:\(messageID), body: \(body.length) bytes"
        s +=  ", crc: 0x\(try! crc.toHex()))"
        return s
    }
}

// MARK: -

extension Message: Equatable {
}

public func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.data == rhs.data
}


