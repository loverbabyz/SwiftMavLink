//
//  DefinitionsSuite.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 9/19/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public class DefinitionsSuite {

    public static var sharedSuite = DefinitionsSuite()

    var cachedDefinitions:[UInt8:MessageDefinition] = [:]
    let lock = NSLock()

    func documents() throws -> [NSXMLDocument] {
        let bundle = NSBundle(identifier: "io.schwa.SwiftMavlink")!
        let commonURLs = [
            bundle.URLForResource("common", withExtension: "xml")!,
            bundle.URLForResource("ardupilotmega", withExtension: "xml")!,
        ]
        return try commonURLs.map() {
            return try NSXMLDocument(contentsOfURL: $0, options: 0)
        }
    }

    public func preload() throws {
        lock.lock()
        defer {
            lock.unlock()
        }

        for xmlDocument in try documents() {
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

        for xmlDocument in try documents() {
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