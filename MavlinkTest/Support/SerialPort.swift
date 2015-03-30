//
//  SerialPort.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

import Darwin

class SerialPort {

    let ioObject:IOObject
    var fileDescriptor:Int32 = -1
    var channel:dispatch_io_t!
    var buffer:dispatch_data_t!

    init(ioObject:IOObject) {
        self.ioObject = ioObject
    }

    deinit {
        if fileDescriptor >= 0 {
            close(fileDescriptor)
        }
    }


    func open() {
        let device = self.ioObject.properties["IOCalloutDevice"] as! String
        fileDescriptor = Darwin.open(device, O_RDONLY)
        assert(fileDescriptor >= 0)

        var term = termios()
        var result = tcgetattr(fileDescriptor, &term)
        assert(result == 0)

        // 115200 / 8 data bits 8 / no parity / 1 stop bit / no flow control

        // 115200 baud
        result = cfsetspeed(&term, speed_t(B115200))
        assert(result == 0)

        // 8 Data bits
        term.c_cflag |= tcflag_t(CS8)

        // No parity
        term.c_cflag &= ~tcflag_t(PARENB);
        term.c_cflag &= ~tcflag_t(PARODD);

        // 1 Stop bit
		term.c_cflag &= ~tcflag_t(CSTOPB);

        result = tcsetattr(fileDescriptor, TCSANOW, &term)
        assert(result == 0)

        channel = dispatch_io_create(DISPATCH_IO_STREAM, dispatch_fd_t(fileDescriptor), dispatch_get_main_queue()) {
            println("cleanup \($0)")
        }

        read()
    }


    func read() {


        dispatch_io_read(channel, 0, 16, dispatch_get_main_queue()) {
            [unowned self] (done:Bool, data:dispatch_data_t!, error:Int32) -> Void in

//            println(done)
//            println(data)
//            println(error)

            if self.buffer == nil {
                self.buffer = data
            }
            else {
                self.buffer = dispatch_data_create_concat(self.buffer, data)
            }

            println(dispatch_data_get_size(self.buffer))
            if dispatch_data_get_size(self.buffer) > 512 {
                println(self.buffer)
                self.buffer = nil
            }


            self.read()

        }
    }



}


