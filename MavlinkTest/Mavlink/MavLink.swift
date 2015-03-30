//
//  MavLink.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

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

//    static func stringForSeed(# name:String, fields:[FieldDefinition]) -> String {
//        var s = ""
//        s += (name + " ")
//        for f in fields {
//            s += (f.type.name + " ")
//            s += (f.name + " ")
//            if let count = f.count {
//                s += ("\(count)")
//            }
//        }
//        return s
//    }


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

extension FieldDefinition: Printable {
    var description: String {
        get {
            return name
        }
    }
}

// MARK: -

enum FieldType {
    case char
    case uint8_t
    case uint32_t

    init?(string:String) {
        switch string {
            case "char":
                self = .char
            case "uint8_t", "uint8_t_mavlink_version":
                self = .uint8_t
            case "uint32_t":
                self = .uint32_t
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
                case .uint32_t:
                    return "uint32_t"
            }
        }
    }

    var size:Int {
        get {
            switch self {
                case .char, .uint8_t:
                    return 1
                case .uint32_t:
                    return 4
            }
        }
    }
}

// MARK: -

extension DataScanner {
    mutating func scan(type:FieldType, count:Int?) -> Any? {
        switch type {
            case .char:
                let count = count ?? 1
                let string:String? = scanString(count)
                return string
            case .uint8_t:
                assert(count == nil)
                return scan() as UInt8?
            case .uint32_t:
                assert(count == nil)
                return scan() as UInt32?
        }
    }
}

// MARK: -

class DefinitionsSuite {

    static var sharedSuite = DefinitionsSuite()
    
    func messageDefinitionWithID(messageID:Int) -> MessageDefinition? {
        // TODO: Do not download this from network. That's just silly!
//        let commonURL = NSURL(fileURLWithPath: "/Users/schwa/Desktop/mavlink/message_definitions/v1.0/common.xml")
        let commonURL = NSURL(string: "https://raw.githubusercontent.com/mavlink/mavlink/master/message_definitions/v1.0/common.xml")
        let xmlDocument = NSXMLDocument(contentsOfURL: commonURL!, options: 0, error: nil)
        let xpath = "/mavlink/messages/message[@id=\(messageID)]"
        var error:NSError?
        let nodes = xmlDocument!.nodesForXPath(xpath, error: &error) as? [NSXMLElement]
        let messageNode = nodes?.last
        let messageDefinition = MessageDefinition(xml:messageNode!)!
        return messageDefinition
    }
}

// MARK: -

struct Message {
    let definition:MessageDefinition!
    let sequence:UInt8!
    let systemID:UInt8!
    let componentID:UInt8!
    let messageID:UInt8!
    let payload:UnsafeBufferPointer <UInt8>!
}

extension Message {
    
    init?(buffer:UnsafeBufferPointer <UInt8>) {
        
        if buffer.count < 8 {
            println("Buffer too small")
            return nil
        }
        
        var scanner = DataScanner(buffer: buffer)
        
        let header = scanner.scan(0xFE)
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
        assert(scanner.atEnd)
        
        if let payloadLength = payloadLength, let sequence = sequence, let systemID = systemID, let componentID = componentID, let messageID = messageID, let payload = payload, let crc = crc {
            definition = DefinitionsSuite.sharedSuite.messageDefinitionWithID(Int(messageID))
            
            let computedCRC = Message.computeCRC(buffer, seed:definition.seed)
            if computedCRC != crc {
                println("Conputed CRC doesn't agree with CRC")
                return nil
            }
            
            self.sequence = sequence
            self.systemID = systemID
            self.componentID = componentID
            self.messageID = messageID
            self.payload = payload
        }
        else {
            println("Could not scan message")
            return nil
        }
    }
    
    func valueAtOffset <T> (# offset:Int, size:Int) -> T? {
        assert(size == sizeof(T))
        let ptr = payload.baseAddress.advancedBy(offset)
        let typedPtr = UnsafePointer <T> (ptr)
        return typedPtr.memory
    }
    
    var values:[String:Any] {
        get {
            var values:[String:Any] = [:]
            var payloadScanner = DataScanner(buffer: payload!)
            for field in definition.fields {
                var value:Any? = payloadScanner.scan(field.type, count:field.count)
                values[field.name] = value
            }
            assert(payloadScanner.atEnd)
            return values
        }
    }
    
    static func computeCRC(buffer:UnsafeBufferPointer <UInt8>, seed:UInt8) -> UInt16! {
        if buffer.count < 4 {
            println("Buffer too small to CRC")
            return nil
        }
        let subBuffer = UnsafeBufferPointer <UInt8> (start:buffer.baseAddress.advancedBy(1), count:buffer.count - 3)
        var crc = CRC16()
        crc.accumulate(subBuffer)
        crc.accumulate([seed])
        return crc.crc
    }
    
}
