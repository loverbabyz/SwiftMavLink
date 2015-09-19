//
//  MavlinkDefinitions.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 9/19/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

import SwiftUtilities

public struct MessageDefinition {
    public let id:Int
    public let name:String
    public let fields:[FieldDefinition]
    public let fieldsByName:[String:FieldDefinition]
    public let seed:UInt8

    public init(id:Int, name:String, fields:[FieldDefinition]) {
        self.id = id
        self.name = name

        var offset = 0
        self.fields = fields.sort(<).map {
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
//        print("Seed: \(seed) \"\(s)\"")
    }

    static func computeSeed(name name:String, fields:[FieldDefinition]) -> UInt8 {
        var crc = SwiftUtilities.CRC16()
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

    public var stringForSeed:String {
        get {
            return MessageDefinition.stringForSeed(name:name, fields:fields)
        }
    }

    static func stringForSeed(name  name:String, fields:[FieldDefinition]) -> String {
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

extension MessageDefinition: CustomStringConvertible {
    public var description: String {
        get {
            return "MessageDefinition(id:\(id), name:\(name), fields:\(fields), seed:\(seed))"
        }
    }
}

// MARK: -

public struct FieldDefinition {
    public let index:Int
    public let type:FieldType
    public let count:Int?
    public let name:String
    public let fieldDescription:String
    public var offset:Int!
}

extension FieldDefinition: Equatable {
}

public func ==(lhs:FieldDefinition, rhs:FieldDefinition) -> Bool {
    return lhs.index == rhs.index && lhs.type.size == rhs.type.size
}

extension FieldDefinition: Comparable {
}

public func <(lhs:FieldDefinition, rhs:FieldDefinition) -> Bool {
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

extension FieldDefinition: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return name
    }
    public var debugDescription: String {
        return "FieldDefinition(index:\(index), type:\(type), count:\(count), name:\(name), offset:\(offset))"
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


public enum FieldType {
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

    public init(string:String) throws {
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
                throw Error.generic("Unknown field type: \(string)")
        }
    }

    public var name:String {
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

    public var size:Int {
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

// MARK: -

public extension DataScanner {
    func scan(type:FieldType, count:Int?) throws -> Any? {
        switch type {
            case .char:
                let count = count ?? 1
                let string:String? = try scanString(count)
                return string
            case .uint8_t:
                assert(count == nil)
                return try scan() as UInt8?
            case .int8_t:
                assert(count == nil)
                return try scan() as Int8?
            case .uint16_t:
                assert(count == nil)
                return try scan() as UInt16?
            case .int16_t:
                assert(count == nil)
                return try scan() as Int16?
            case .uint32_t:
                assert(count == nil)
                return try scan() as UInt32?
            case .int32_t:
                assert(count == nil)
                return try scan() as Int32?
            case .uint64_t:
                assert(count == nil)
                return try scan() as UInt64?
            case .int64_t:
                assert(count == nil)
                return try scan() as Int64?
            case .float:
                assert(count == nil)
                return try scan() as Float?
            case .double:
                assert(count == nil)
                return try scan() as Double?
        }
    }
}

// MARK: -

public class DefinitionsSuite {

    public static var sharedSuite = DefinitionsSuite()

    var cachedDefinitions:[UInt8:MessageDefinition] = [:]
    var lock = NSLock()

    public func preload() throws {

        lock.lock()
        defer {
            lock.unlock()
        }

        let bundle = NSBundle(identifier: "io.schwa.SwiftMavlink")!

        let commonURLs = [
            bundle.URLForResource("common", withExtension: "xml")!,
            bundle.URLForResource("ardupilotmega", withExtension: "xml")!,
        ]

        for commonURL in commonURLs {
            let xmlDocument = try NSXMLDocument(contentsOfURL: commonURL, options: 0)
            let xpath = "/mavlink/messages/message"
            guard let nodes = try xmlDocument.nodesForXPath(xpath) as? [NSXMLElement] else {
                break
            }
            for messageNode in nodes {

                guard let idString = messageNode.attributeForName("id")?.stringValue else {
                    print("No ID")
                    continue
                }
                guard let messageID = UInt8(idString) else {
                    print("ID not integer")
                    continue
                }
                let definition = try MessageDefinition(xml:messageNode)

                if cachedDefinitions[messageID] != nil {
                    print("Already an entry for \(definition.name)")
                }

                cachedDefinitions[messageID] = definition
            }
        }
    }

    public func messageDefinitionWithID(messageID:UInt8) throws -> MessageDefinition? {

        lock.lock()
        defer {
            lock.unlock()
        }

        if let definition = cachedDefinitions[messageID] {
            return definition
        }

        let bundle = NSBundle(identifier: "io.schwa.SwiftMavlink")!

        let commonURLs = [
            bundle.URLForResource("common", withExtension: "xml")!,
            bundle.URLForResource("ardupilotmega", withExtension: "xml")!,
        ]

        for commonURL in commonURLs {
            let xmlDocument = try NSXMLDocument(contentsOfURL: commonURL, options: 0)
            let xpath = "/mavlink/messages/message[@id=\(messageID)]"
            guard let nodes = try xmlDocument.nodesForXPath(xpath) as? [NSXMLElement] else {
                break
            }
            guard let messageNode = nodes.last else {
                break
            }
            let definition = try MessageDefinition(xml:messageNode)
            cachedDefinitions[messageID] = definition
            return definition
        }

        return nil
    }
}