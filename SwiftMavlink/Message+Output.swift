//
//  Message+Output.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 9/19/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import SwiftUtilities

public extension Message {

    public init(sequence: UInt8, systemID: UInt8, componentID: UInt8, definition:MessageDefinition, body: DispatchData <Void>) throws {
        self.sequence = sequence
        self.systemID = systemID
        self.componentID = componentID
        self.messageID = definition.id
        self.body = body
        self.definition = definition

        let header = DispatchData <UInt8> ([ 0xFE, UInt8(body.length), sequence, systemID, componentID, messageID ])
        let footer = DispatchData <UInt16> ([ 0 ])
        let data = header.toDispatchData() + body + footer.toDispatchData()

        crc = try data.createMap() {
            (_, ptr) in
            return try Message.computeCRC(ptr, seed:definition.seed)
        }
    }

    public init(sequence: UInt8, systemID: UInt8, componentID: UInt8, messageID: UInt8, values: [String:Any]) throws {
        guard let definition = try DefinitionsSuite.sharedSuite.messageDefinitionWithID(messageID) else {
            throw Error.generic("No definition found for messageID: \(messageID)")
        }

        guard let data = NSMutableData(capacity: 255) else {
            fatalError()
        }

        for field in definition.fields {
            guard let value = values[field.name] else {
                throw Error.generic("No value found for field \(field.name)")
            }
            try data.append(field, value: value)
        }

        let body = DispatchData <Void> (start: data.bytes, count:data.length)
        try self.init(sequence: sequence, systemID: systemID, componentID: componentID, definition: definition, body: body)
    }
}

// MARK: -

private extension NSMutableData {

    func append(field:FieldDefinition, value:Any) throws {

        // TODO: Endian!?

        switch field.type {
            case .char:
                guard let actualCount = field.count else {
                    throw Error.generic("String field has no defined count")
                }
                guard let string = value as? String else {
                    throw Error.generic("Could not convert \(value) to String")
                }
                try string.withCString() {
                    (buffer) in
                    let count = Int(strlen(buffer))
                    guard count <= actualCount else {
                        throw Error.generic("String too large for field.")
                    }
                    appendBytes(buffer, length: count)
                    let zeros = Array <UInt8> (count: actualCount - count, repeatedValue: 0)
                    zeros.withUnsafeBufferPointer() {
                        (buffer) in
                        appendBytes(buffer.baseAddress, length: buffer.count)
                    }
                }
            case .uint8_t:
                if let count = field.count {
                    try append(value as? [UInt8], count:count)
                }
                else {
                    try append(value as? UInt8)
                }
            case .int8_t:
                if let count = field.count {
                    try append(value as? [Int8], count:count)
                }
                else {
                    try append(value as? Int8)
                }
            case .uint16_t:
                if let count = field.count {
                    try append(value as? [UInt16], count:count)
                }
                else {
                    try append(value as? UInt16)
                }
            case .int16_t:
                if let count = field.count {
                    try append(value as? [Int16], count:count)
                }
                else {
                    try append(value as? Int16)
                }
            case .uint32_t:
                if let count = field.count {
                    try append(value as? [UInt32], count:count)
                }
                else {
                    try append(value as? UInt32)
                }
            case .int32_t:
                if let count = field.count {
                    try append(value as? [Int32], count:count)
                }
                else {
                    try append(value as? Int32)
                }
            case .uint64_t:
                if let count = field.count {
                    try append(value as? [UInt64], count:count)
                }
                else {
                    try append(value as? UInt64)
                }
            case .int64_t:
                if let count = field.count {
                    try append(value as? [Int64], count:count)
                }
                else {
                    try append(value as? Int64)
                }
            case .float:
                if let count = field.count {
                    try append(value as? [Float], count:count)
                }
                else {
                    try append(value as? Float)
                }
            case .double:
                if let count = field.count {
                    try append(value as? [Double], count:count)
                }
                else {
                    try append(value as? Double)
                }
        }
    }

    func append <T> (value:T?) throws {
        guard var typedValue = value else {
            throw Error.generic("Could not convert \(value) to \(T.self)")
        }
        withUnsafePointer(&typedValue) {
            (pointer) in
            appendBytes(pointer, length: sizeof(T))
        }
    }

    func append <T> (value:[T]?, count:Int) throws {
        guard let typedValue = value else {
            throw Error.generic("Could not convert \(value) to [\(T.self)]")
        }
        guard typedValue.count == count else {
            throw Error.generic("Array count does not match expectations")
        }
        typedValue.withUnsafeBufferPointer() {
            (buffer) in
            appendBytes(buffer.baseAddress, length: buffer.length)
        }
    }
}
