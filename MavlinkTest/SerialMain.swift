//
//  Tests.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/30/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

//import IOKit
//import IOKit.serial
//
//let matching = (IOServiceMatching(kIOSerialBSDServiceValue).takeRetainedValue() as NSMutableDictionary)
//
//matching[kIOSerialBSDTypeKey] = kIOSerialBSDRS232Type
//matching[kIOTTYBaseNameKey] = "usbserial-DN009LZP"
//
//var iterator:io_iterator_t = 0
//var object:IOObject?
//var result = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iterator)
//while true {
//    object = IOObject(object:IOIteratorNext(iterator))
//    if object == nil {
//        break
//    }
//    break
//}
//
//let port = SerialPort(ioObject: object!)
//port.open()
//
//
//dispatch_main()
