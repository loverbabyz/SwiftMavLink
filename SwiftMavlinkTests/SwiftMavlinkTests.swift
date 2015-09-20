//
//  SwiftMavlinkTests.swift
//  SwiftMavlinkTests
//
//  Created by Jonathan Wight on 9/19/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import XCTest

import SwiftMavlink
import SwiftUtilities

class SwiftMavlinkTests: XCTestCase {
    func testPing() {
        let values: [String:Any] = [
            "time_usec": UInt64(1),
            "seq": UInt32(2),
            "target_system": UInt8(3),
            "target_component": UInt8(4),
        ]
        let message = try! Message(sequence: 0, systemID: 0, componentID: 0, messageID: 4, values: values)
        XCTAssertEqual(String(message.values), String(values))
        let data = message.data
        let reparsedMessage = try! Message(data: data, skipCRC: false)
        XCTAssertEqual(message, reparsedMessage)
        XCTAssertEqual(String(message.values), String(reparsedMessage.values))
    }

    func testStatusText() {
        let values:[String:Any] = [
            "severity": UInt8(1),
            "text": "Hello world",
        ]
        let message = try! Message(sequence: 0, systemID: 0, componentID: 0, messageID: 253, values: values)
        XCTAssertEqual(String(message.values), String(values))
        let data = message.data
        let reparsedMessage = try! Message(data: data, skipCRC: false)
        XCTAssertEqual(message, reparsedMessage)
    }
}
