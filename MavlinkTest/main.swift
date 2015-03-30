//
//  main.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

// #############################################################################

//let data = "fe09000b1600ffffffff020180030022d8"
let data = "fe33000b16fd014f4f505300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b32f"
let d = NSData(hexString: data)
let buffer:UnsafeBufferPointer <UInt8> = d!.buffer.asUnsafeBufferPointer()

let message = Message(buffer: buffer)!

//let fieldDefinition = message.definition.fieldsByName["system_status"]!
//let offset = fieldDefinition.offset
//let size = fieldDefinition.type.size
//let value:UInt8? = message.valueAtOffset(offset:offset, size:size)
//println(value)

println("\(message.definition.name): \(message.values)")




