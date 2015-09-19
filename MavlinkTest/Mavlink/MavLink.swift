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
    public let sequence:UInt8
    public let systemID:UInt8
    public let componentID:UInt8
    public let messageID:UInt8
    public let payload:DispatchData <Void>
    public let crc:UInt16
    public let definition:MessageDefinition?

    public var length:Int {
        return 6 + payload.count + 2
    }
}

public extension Message {
    
    public init(buffer:UnsafeBufferPointer <Void>, skipCRC:Bool = false) throws {
        
        guard buffer.count >= 8 else {
            throw Error.generic("Buffer too small")
        }
        
        let scanner = DataScanner(buffer: buffer)
        
        guard try scanner.scan(0xFE) == true else {
            throw Error.generic("No header found.")
        }

        guard let payloadLength:UInt8 = try scanner.scan() else {
            throw Error.generic("No payload length found.")
        }

        guard buffer.count >= 8 + Int(payloadLength) else {
            throw Error.generic("Buffer size (\(buffer.count)) doesn't agree with payload length (\(payloadLength + 8)): \(try? buffer.toHex())")
        }

        sequence = try scanner.scan()
        systemID = try scanner.scan()
        componentID = try scanner.scan()
        messageID = try scanner.scan()
        payload = try scanner.scan(Int(payloadLength))!
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

//    public func valueAtOffset <T> (offset offset:Int, size:Int) throws -> T {
//        assert(size == sizeof(T))
//        let ptr = payload.bufferPointer.baseAddress.advancedBy(offset)
//        let typedPtr = UnsafePointer <T> (ptr)
//        return typedPtr.memory
//    }

    public var values:[String:Any] {
        guard let definition = definition else {
            return [:]
        }

        var values:[String:Any] = [:]

        payload.createMap() {
            (_, buffer) in
            let payloadScanner = DataScanner(buffer: buffer)
            for field in definition.fields {
                let value:Any? = try! payloadScanner.scan(field.type, count:field.count)
                values[field.name] = value
            }
        }


        return values
    }
    
    public static func computeCRC(buffer:UnsafeBufferPointer <Void>, seed:UInt8) throws -> UInt16! {

        let buffer:UnsafeBufferPointer <UInt8> = buffer.toUnsafeBufferPointer()

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

extension Message: CustomStringConvertible {
    public var description: String {
        var s = "Message(sequence:\(sequence), systemID:\(systemID), componentID:\(componentID), messageID:\(messageID)"
        s +=  ", crc: 0x\(try? crc.toHex()))"
        return s
    }
}



public extension DataScanner {

    func scan(count: Int) throws -> DispatchData <Void>? {
        if remainingSize < count {
            return nil
        }
        let scannedBuffer = UnsafeBufferPointer <Void> (start: buffer.baseAddress.advancedBy(current), count: count)
        current = current.advancedBy(count)
        return DispatchData <Void> (buffer:scannedBuffer)
    }
}