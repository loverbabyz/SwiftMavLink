//
//  Mavlink+Input.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 9/19/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import SwiftUtilities

public extension Message {
    
    public init(buffer:UnsafeBufferPointer <Void>, skipCRC:Bool = false) throws {
        
        guard buffer.count >= 8 else {
            throw Error.generic("Buffer too small")
        }

        // TODO: Endian!?
        
        let scanner = DataScanner(buffer: buffer)
        
        guard try scanner.scan(0xFE) == true else {
            throw Error.generic("No header found.")
        }

        guard let bodyLength:UInt8 = try scanner.scan() else {
            throw Error.generic("No body length found.")
        }

        guard buffer.count >= 8 + Int(bodyLength) else {
            throw Error.generic("Buffer size (\(buffer.count)) doesn't agree with body length (\(bodyLength + 8)): \(try? buffer.toHex())")
        }

        sequence = try scanner.scan()
        systemID = try scanner.scan()
        componentID = try scanner.scan()
        messageID = try scanner.scan()
        body = try scanner.scan(Int(bodyLength))!
        crc = try scanner.scan()
        definition = try DefinitionsSuite.sharedSuite.messageDefinitionWithID(messageID)

        if let definition = definition {
            let computedCRC = try Message.computeCRC(buffer, seed:definition.seed)
            if computedCRC != crc {
                if skipCRC == false {
                    throw Error.generic("Computed CRC (\(try? computedCRC.toHex())) doesn't agree with (\(try? crc.toHex()))")
                }
            }
        }
    }

    public var values: [String:Any] {
        do {
            return try readValues()
        }
        catch {
            return [:]
        }
    }

    func readValues() throws -> [String:Any] {
        guard let definition = definition else {
            throw Error.generic("No definition found for message id: \(messageID)")
        }

        var values: [String:Any] = [:]

        try body.createMap() {
            (_, buffer) in
            let bodyScanner = DataScanner(buffer: buffer)
            for field in definition.fields {
                let value:Any? = try bodyScanner.scan(field.type, count:field.count)
                values[field.name] = value
            }
        }
        return values
    }

    public static func computeCRC(buffer: UnsafeBufferPointer <Void>, seed: UInt8) throws -> UInt16 {
        let buffer: UnsafeBufferPointer <UInt8> = buffer.toUnsafeBufferPointer()

        guard buffer.count >= 4 else {
            throw Error.generic("Buffer too small to CRC")
        }

        let length = buffer[1]
        let subBuffer = UnsafeBufferPointer <UInt8> (start:buffer.baseAddress.advancedBy(1), count:Int(length) + 5)
        var crc = CRC16()
        crc.accumulate(subBuffer)
        crc.accumulate([seed])
        return crc.crc
    }
}

