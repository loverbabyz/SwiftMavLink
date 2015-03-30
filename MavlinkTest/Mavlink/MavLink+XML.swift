//
//  MavLink+XML.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/30/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

// MARK: -

extension MessageDefinition {
    init?(xml element:NSXMLElement) {
        let id = element.attributeForName("id")!.stringValue!.toInt()!
        let name = element.attributeForName("name")!.stringValue!
        let fieldNodes = element.nodesForXPath("field", error: nil) as? [NSXMLElement]
        let fields = map(enumerate(fieldNodes!)) {
            (index:Int, element:NSXMLElement) -> FieldDefinition in
            return FieldDefinition(xml:element, index:index)!
        }

        self.init(id:id, name:name, fields:fields)
    }
}

extension FieldDefinition {

    static let expression = RegularExpression("([^\\[]+)(?:\\[(.+)\\])?")

    static func fromXMLElement(element:NSXMLElement, index:Int) -> FieldDefinition? {
        if let typeString = element.attributeForName("type")?.stringValue {
            let match = expression.match(typeString)
            if let match = match, let typeName = match.strings[1] {
                let type = FieldType(string:typeName)
                let name = element.attributeForName("name")?.stringValue
                let fieldDescription = element.stringValue

                if let type = type, let name = name, let fieldDescription = fieldDescription {
                    let count = match.strings[2]?.toInt() ?? nil
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
