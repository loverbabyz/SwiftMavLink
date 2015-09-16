//
//  MavLink+XML.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/30/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

import SwiftUtilities

// MARK: -

public extension MessageDefinition {
    init(xml element:NSXMLElement) throws {

        guard let string_id = element.attributeForName("id")?.stringValue, let id = Int(string_id) else {
            throw Error.generic("No id")
        }

        guard let name = element.attributeForName("name")?.stringValue else {
            throw Error.generic("No name")
        }
        
        guard let fieldNodes = try element.nodesForXPath("field") as? [NSXMLElement] else {
            throw Error.generic("No fields")
        }

        let fields = fieldNodes.enumerate().map() {
            (index, element) -> FieldDefinition in
            return try! FieldDefinition(xml:element, index:index)
        }

        self.init(id:id, name:name, fields:fields)
    }
}

// MARK: -

public extension FieldDefinition {

    static let expression = try! RegularExpression("([^\\[]+)(?:\\[(.+)\\])?")

    static func fromXMLElement(element:NSXMLElement, index:Int) throws -> FieldDefinition {
        guard let typeString = element.attributeForName("type")?.stringValue else {
            throw Error.generic("Could not get type from field definition.")
        }

        guard let match = expression.match(typeString) else {
            throw Error.generic("Type definition does not match regex.")
        }

        guard let typeName = match.strings[1] else {
            throw Error.generic("Could not find field description (probably a bad regex).")
        }

        let type = try FieldType(string:typeName)

        guard let fieldDescription = element.stringValue else {
            throw Error.generic("Could not get field description.")
        }

        guard let name = element.attributeForName("name")?.stringValue else {
            throw Error.generic("Could not get name from field definition.")
        }

        let count:Int? = match.strings[2] != nil ? Int(match.strings[2]!) : nil
        return FieldDefinition(index:index, type:type, count:count, name:name, fieldDescription:fieldDescription, offset:nil)

    }

    init(xml element:NSXMLElement, index:Int) throws {
        self = try FieldDefinition.fromXMLElement(element, index:index)
    }
}