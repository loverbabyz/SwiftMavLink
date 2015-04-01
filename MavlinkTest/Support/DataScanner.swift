//
//  DataScanner.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

class DataScanner {
    typealias BufferType = UnsafeBufferPointer <UInt8>
    let buffer:BufferType
    var current:BufferType.Index

    var remaining:BufferType {
        get {
            return BufferType(start: buffer.baseAddress + current, count: buffer.count - current)
        }
    }

    init(buffer:BufferType) {
        self.buffer = buffer
        current = self.buffer.startIndex
    }

    func scan() -> UInt8? {
        if atEnd {
            return nil
        }
        let result = buffer[current]
        current = current.advancedBy(1)
        return result
    }


    func scan() -> Int8? {
        if let unsigned:UInt8 = scan() {
            return Int8(bitPattern:unsigned)
        }
        else {
            return nil
        }
    }

    func scan() -> UInt16? {
        typealias Type = UInt16
        if atEnd {
            return nil
        }
        let offset = buffer.baseAddress.advancedBy(current)
        let b = UnsafePointer <Type> (offset)
        let result = b.memory
        // TODO; Endianness
        current = current.advancedBy(sizeof(Type))
        return result
    }

    func scan() -> Int16? {
        if let unsigned:UInt16 = scan() {
            return Int16(bitPattern:unsigned)
        }
        else {
            return nil
        }
    }

    func scan() -> UInt32? {
        typealias Type = UInt32
        if atEnd {
            return nil
        }
        let offset = buffer.baseAddress.advancedBy(current)
        let b = UnsafePointer <Type> (offset)
        let result = b.memory
        // TODO; Endianness
        current = current.advancedBy(sizeof(Type))
        return result
    }

    func scan() -> Int32? {
        if let unsigned:UInt32 = scan() {
            return Int32(bitPattern:unsigned)
        }
        else {
            return nil
        }
    }

    func scan() -> UInt64? {
        typealias Type = UInt64
        if atEnd {
            return nil
        }
        let offset = buffer.baseAddress.advancedBy(current)
        let b = UnsafePointer <Type> (offset)
        let result = b.memory
        // TODO; Endianness
        current = current.advancedBy(sizeof(Type))
        return result
    }

    func scan() -> Int64? {
        if let unsigned:UInt64 = scan() {
            return Int64(bitPattern:unsigned)
        }
        else {
            return nil
        }
    }


    func scan() -> Float? {
        typealias Type = Float
        if atEnd {
            return nil
        }
        let offset = buffer.baseAddress.advancedBy(current)
        let b = UnsafePointer <Type> (offset)
        let result = b.memory
        // TODO; Endianness
        current = current.advancedBy(sizeof(Type))
        return result
    }

    func scan() -> Double? {
        typealias Type = Double
        if atEnd {
            return nil
        }
        let offset = buffer.baseAddress.advancedBy(current)
        let b = UnsafePointer <Type> (offset)
        let result = b.memory
        // TODO; Endianness
        current = current.advancedBy(sizeof(Type))
        return result
    }

    func scan(value:UInt8) -> Bool {
        if let scannedValue:UInt8 = scan() {
            return scannedValue == value
        }
        else {
            return false
        }
    }

    func scanBuffer(count:Int) -> UnsafeBufferPointer <UInt8>? {
        if atEnd {
            return nil
        }
        let scannedBuffer = UnsafeBufferPointer <UInt8> (start: buffer.baseAddress.advancedBy(current), count: count)
        current = current.advancedBy(count)
        return scannedBuffer
    }

    func scanString(count:Int) -> String? {
        if atEnd {
            return nil
        }
        if let buffer:UnsafeBufferPointer <CChar> = scanBuffer(count)?.asUnsafeBufferPointer() {
            // TODO: bil byte???

            // Use NSData etc

            return String.fromCString(buffer.baseAddress)
        }
        else {
            return nil
        }
    }

    var atEnd:Bool {
        get {
            return current == buffer.endIndex
        }
    }
}
