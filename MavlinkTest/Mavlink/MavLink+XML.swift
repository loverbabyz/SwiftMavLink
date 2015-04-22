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
    init?(xml element:NSXMLElement) {
        let id = Int(element.attributeForName("id")!.stringValue!)!
        let name = element.attributeForName("name")!.stringValue!
        let fieldNodes = try! element.nodesForXPath("field")

        let fields = (fieldNodes as? [NSXMLElement])!.enumerate().map() {
            (index:Int, element:NSXMLElement) -> FieldDefinition in
            return FieldDefinition(xml:element, index:index)!
        }

        self.init(id:id, name:name, fields:fields)
    }
}

// MARK: -

public extension FieldDefinition {

    static let expression = try! RegularExpression("([^\\[]+)(?:\\[(.+)\\])?")

    static func fromXMLElement(element:NSXMLElement, index:Int) -> FieldDefinition? {
        if let typeString = element.attributeForName("type")?.stringValue {
            if let match = expression.match(typeString) {
                let typeName = match.strings[1]!
                let type = FieldType(string:typeName)
                let name = element.attributeForName("name")?.stringValue
                let fieldDescription = element.stringValue

                if let type = type, let name = name, let fieldDescription = fieldDescription {
                    let count:Int? = match.strings[2]?.toInt()
                    return FieldDefinition(index:index, type:type, count:count, name:name, fieldDescription:fieldDescription, offset:nil)
                }
            }
        }
        return nil
    }

    init?(xml element:NSXMLElement, index:Int) {
        if let definition = FieldDefinition.fromXMLElement(element, index:index) {
            self = definition
        }
        else {
            return nil
        }
    }
}