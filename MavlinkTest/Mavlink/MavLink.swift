//
//  MavLink.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

struct MessageDefinition {
    let id:Int
    let name:String
    let fields:[FieldDefinition]
    let fieldsByName:[String:FieldDefinition]
    let seed:UInt8

    init(id:Int, name:String, fields:[FieldDefinition]) {
        self.id = id
        self.name = name

        var offset = 0
        self.fields = map(fields.sorted(<)) {
            let field = FieldDefinition(index: $0.index, type: $0.type, count: $0.count, name: $0.name, fieldDescription: $0.fieldDescription, offset: offset)
            offset += $0.type.size
            return field
        }

        var fieldsByName:[String:FieldDefinition] = [:]
        for f in self.fields {
            fieldsByName[f.name] = f
        }
        self.fieldsByName = fieldsByName

        seed = MessageDefinition.computeSeed(name:name, fields:self.fields)
//        let s = MessageDefinition.stringForSeed(name:name, fields:self.fields)
//        println("Seed: \(seed) \"\(s)\"")
    }

    static func computeSeed(# name:String, fields:[FieldDefinition]) -> UInt8 {
        var crc = CRC16()
        crc.accumulate(name + " ")
        for f in fields {
            crc.accumulate(f.type.name + " ")
            crc.accumulate(f.name + " ")
            if let count = f.count {
                crc.accumulate([UInt8(count)])
            }
        }
        return UInt8((crc.crc & 0xFF) ^ (crc.crc >> 8))
    }

    var stringForSeed:String {
        get {
            return MessageDefinition.stringForSeed(name:name, fields:fields)
        }
    }

    static func stringForSeed(# name:String, fields:[FieldDefinition]) -> String {
        var s = ""
        s += (name + " ")
        for f in fields {
            s += (f.type.name + " ")
            s += (f.name + " ")
            if let count = f.count {
                s += ("\(count)")
            }
        }
        return s
    }
}

extension MessageDefinition: Printable {
    var description: String {
        get {
            return "MessageDefinition(id:\(id), name:\(name), fields:\(fields), seed:\(seed))"
        }
    }
}

// MARK: -

struct FieldDefinition {
    let index:Int
    let type:FieldType
    let count:Int?
    let name:String
    let fieldDescription:String
    var offset:Int!
}

extension FieldDefinition: Equatable {
}

func ==(lhs:FieldDefinition, rhs:FieldDefinition) -> Bool {
    return lhs.index == rhs.index && lhs.type.size == rhs.type.size
}

extension FieldDefinition: Comparable {
}

func <(lhs:FieldDefinition, rhs:FieldDefinition) -> Bool {
    if lhs.type.size > rhs.type.size {
        return true
    }
    else if lhs.type.size < rhs.type.size {
        return false
    }
    else {
        return lhs.index < rhs.index
    }
}

extension FieldDefinition: Printable, DebugPrintable {
    var description: String {
        get {
            return name
        }
    }
    var debugDescription: String {
        get {
            return "FieldDefinition(index:\(index), type:\(type), count:\(count), name:\(name), offset:\(offset))"
        }
    }
}

// MARK: -

//# # some base types from mavlink_types.h
//# MAVLINK_TYPE_CHAR     = 0
//# MAVLINK_TYPE_UINT8_T  = 1
//# MAVLINK_TYPE_INT8_T   = 2
//# MAVLINK_TYPE_UINT16_T = 3
//# MAVLINK_TYPE_INT16_T  = 4
//# MAVLINK_TYPE_UINT32_T = 5
//# MAVLINK_TYPE_INT32_T  = 6
//# MAVLINK_TYPE_UINT64_T = 7
//# MAVLINK_TYPE_INT64_T  = 8
//# MAVLINK_TYPE_FLOAT    = 9
//# MAVLINK_TYPE_DOUBLE   = 10


enum FieldType {
    case char
    case uint8_t
    case int8_t
    case uint16_t
    case int16_t
    case uint32_t
    case int32_t
    case uint64_t
    case int64_t
    case float
    case double

    init?(string:String) {
        switch string {
            case "char":
                self = .char
            case "uint8_t", "uint8_t_mavlink_version":
                self = .uint8_t
            case "int8_t":
                self = .int8_t
            case "uint16_t":
                self = .uint16_t
            case "int16_t":
                self = .int16_t
            case "uint32_t":
                self = .uint32_t
            case "int32_t":
                self = .int32_t
            case "uint64_t":
                self = .uint64_t
            case "int64_t":
                self = .int64_t
            case "float":
                self = .float
            case "double":
                self = .double
            default:
                println("Unknown field type: \(string)")
                self = .uint8_t
                return nil
        }
    }

    var name:String {
        get {
            switch self {
                case .char:
                    return "char"
                case .uint8_t:
                    return "uint8_t"
                case .int8_t:
                    return "int8_t"
                case .uint16_t:
                    return "uint16_t"
                case .int16_t:
                    return "int16_t"
                case .uint32_t:
                    return "uint32_t"
                case .int32_t:
                    return "int32_t"
                case .uint64_t:
                    return "uint64_t"
                case .int64_t:
                    return "int64_t"
                case .float:
                    return "float"
                case .double:
                    return "double"
            }
        }
    }

    var size:Int {
        get {
            switch self {
                case .char, .uint8_t, .int8_t:
                    return 1
                case .uint16_t, .int16_t:
                    return 2
                case .uint32_t, .int32_t:
                    return 4
                case .uint64_t, .int64_t:
                    return 8
                case .float:
                    return 4
                case .double:
                    return 4
            }
        }
    }
}

extension FieldType: Printable {
    var description: String {
        get {
            return name
        }
    }
}

// MARK: -

extension DataScanner {
    func scan(type:FieldType, count:Int?) -> Any? {
        switch type {
            case .char:
                let count = count ?? 1
                let string:String? = scanString(count)
                return string
            case .uint8_t:
                assert(count == nil)
                return scan() as UInt8?
            case .int8_t:
                assert(count == nil)
                return scan() as Int8?
            case .uint16_t:
                assert(count == nil)
                return scan() as UInt16?
            case .int16_t:
                assert(count == nil)
                return scan() as Int16?
            case .uint32_t:
                assert(count == nil)
                return scan() as UInt32?
            case .int32_t:
                assert(count == nil)
                return scan() as Int32?
            case .uint64_t:
                assert(count == nil)
                return scan() as UInt64?
            case .int64_t:
                assert(count == nil)
                return scan() as Int64?
            case .float:
                assert(count == nil)
                return scan() as Float?
            case .double:
                assert(count == nil)
                return scan() as Double?
        }
    }
}

// MARK: -

class DefinitionsSuite {

    static var sharedSuite = DefinitionsSuite()

    func messageDefinitionWithID(messageID:Int) -> MessageDefinition? {
        // TODO: Do not download this from network. That's just silly!
        let commonURLs = [
            NSURL(string: "https://raw.githubusercontent.com/mavlink/mavlink/master/message_definitions/v1.0/common.xml"),
//            NSURL(fileURLWithPath: "/Users/schwa/Development/Source/Projects/SwiftMavlink/message_definitions/v1.0/common.xml"),
//            NSURL(fileURLWithPath: "/Users/schwa/Development/Source/Projects/SwiftMavlink/message_definitions/v1.0/ardupilotmega.xml")
        ]

        for commonURL in commonURLs {
            let xmlDocument = NSXMLDocument(contentsOfURL: commonURL!, options: 0, error: nil)
            let xpath = "/mavlink/messages/message[@id=\(messageID)]"
            var error:NSError?
            let nodes = xmlDocument!.nodesForXPath(xpath, error: &error) as? [NSXMLElement]
            if let messageNode = nodes?.last {
                let messageDefinition = MessageDefinition(xml:messageNode)
                return messageDefinition
            }
        }

    println("WARNING: No message definition found for  id \(messageID)")
    return nil
    }
}

// MARK: -

struct Message {
    let definition:MessageDefinition?
    let payloadLength:UInt8!
    let sequence:UInt8!
    let systemID:UInt8!
    let componentID:UInt8!
    let messageID:UInt8!
    let payload:UnsafeBufferPointer <UInt8>!
    let crc:UInt16?

    var length:Int {
        get {
            return 6 + payload.count + 2
        }
    }
}

extension Message {
    
    init?(buffer:UnsafeBufferPointer <UInt8>, skipCRC:Bool = false) {
        
        if buffer.count < 8 {
            println("Buffer too small")
            return nil
        }
        
        var scanner = DataScanner(buffer: buffer)
        
        let header = scanner.scan(0xFE)
        if header == false {
            return nil
        }
        let payloadLength:UInt8? = scanner.scan()
        
        if let payloadLength = payloadLength {
            if buffer.count < 8 + Int(payloadLength) {
                println("Buffer size doesn't agree with payload length")
                return nil
            }
        }

        
        let sequence:UInt8? = scanner.scan()
        let systemID:UInt8? = scanner.scan()
        let componentID:UInt8? = scanner.scan()
        let messageID:UInt8? = scanner.scan()
        let payload = scanner.scanBuffer(Int(payloadLength!))
        let crc:UInt16? = scanner.scan()
//        assert(scanner.atEnd)
        
        if let payloadLength = payloadLength, let sequence = sequence, let systemID = systemID, let componentID = componentID, let messageID = messageID, let payload = payload, let crc = crc {
            let definition = DefinitionsSuite.sharedSuite.messageDefinitionWithID(Int(messageID))
            if let definition = definition {
                let computedCRC = Message.computeCRC(buffer, seed:definition.seed)
                if computedCRC != crc {
                    println("WARNING: Computed CRC (\(computedCRC.asHex)) doesn't agree with (\(crc.asHex))")
                    if skipCRC == false {
                        return nil
                    }
                }
            }
            self.definition = definition
            self.payloadLength = payloadLength
            self.sequence = sequence
            self.systemID = systemID
            self.componentID = componentID
            self.messageID = messageID
            self.payload = payload
            self.crc = crc
            return

        }

        println("Could not scan message")
        return nil
    }
    
    func valueAtOffset <T> (# offset:Int, size:Int) -> T? {
        assert(size == sizeof(T))
        let ptr = payload.baseAddress.advancedBy(offset)
        let typedPtr = UnsafePointer <T> (ptr)
        return typedPtr.memory
    }
    
    var values:[String:Any] {
        get {
            if let definition = definition {
                var values:[String:Any] = [:]
                var payloadScanner = DataScanner(buffer: payload!)
                for field in definition.fields {
                    var value:Any? = payloadScanner.scan(field.type, count:field.count)
                    values[field.name] = value
                }
    //            assert(payloadScanner.atEnd)
                return values
            }
            else {
                return [:]
            }
        }
    }
    
    static func computeCRC(buffer:UnsafeBufferPointer <UInt8>, seed:UInt8) -> UInt16! {
        if buffer.count < 4 {
            println("Buffer too small to CRC")
            return nil
        }

        let length = buffer[1]
        let subBuffer = UnsafeBufferPointer <UInt8> (start:buffer.baseAddress.advancedBy(1), count:Int(length) + 5)
        var crc = CRC16()
        crc.accumulate(subBuffer)
        crc.accumulate([seed])
        return crc.crc
    }
    
}

extension Message: Printable {
    var description: String {
        get {
            var s = "Message(payloadLength:\(payloadLength), sequence:\(sequence), systemID:\(systemID), componentID:\(componentID), messageID:\(messageID)"
            if let crc = crc {
                s +=  ", crc: 0x\(crc.asHex))"
            }
            return s
        }
    }
}
