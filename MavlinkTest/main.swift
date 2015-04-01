//
//  main.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

//struct Cursor {
//    var current:Int
//    var startIndex:Int
//    var endIndex:Int
//}

extension DataScanner {

    func scanUpTo(byte:UInt8) -> BufferType? {
        let start = current
        for ; current != buffer.endIndex; ++current {
            if buffer[current] == byte {
                break
            }
        }
        if start == current {
            return nil
        }
        return buffer[start..<current]

    }

    func scan() -> Message? {
        if let message = Message(buffer: remaining, skipCRC:true) {
            current += message.length
            return message
        }
        return nil
    }
}



let url = NSURL(fileURLWithPath: "/Users/schwa/Development/Source/Projects/SwiftMavlink/Logs/2015-03-31 20-51-06.tlog")!
let data = NSData(contentsOfURL: url)!
let buffer:UnsafeBufferPointer <UInt8> = data.buffer.asUnsafeBufferPointer()

let scanner = DataScanner(buffer: buffer)

while scanner.atEnd == false {
    if let junk = scanner.scanUpTo(0xFE) {
//        println("Skipping: \(junk.asHex)")
    }
    let message:Message? = scanner.scan()
    if let message = message {
        println(message.definition?.name)
        println(message)
        println(message.values)
        println("################################################################################")
    }
    else {
        break
    }
}




