//
//  Utilities.swift
//  SwiftMavlink
//
//  Created by Jonathan Wight on 9/19/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import SwiftUtilities

extension DataScanner {
    func scan(count: Int) throws -> DispatchData <Void>? {
        if remainingSize < count {
            return nil
        }
        let scannedBuffer = UnsafeBufferPointer <Void> (start: buffer.baseAddress.advancedBy(current), count: count)
        current = current.advancedBy(count)
        return DispatchData <Void> (buffer:scannedBuffer)
    }
}

extension DispatchData {
    func toDispatchData <U> () -> DispatchData <U> {
        return DispatchData <U> (data: data)
    }
}

extension DispatchData {
    init <U> (_ value:[U]) {
        let data = value.withUnsafeBufferPointer() {
            (buffer) in
            return dispatch_data_create(buffer.baseAddress, buffer.length, nil, nil)
        }
        self.init(data:data)
    }
}
