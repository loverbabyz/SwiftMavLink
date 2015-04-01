# SwiftMavLink

## Introduction

Pure Swift implementation of the MAVLink unmanned vehicle communication protocol

From [Wikipedia](https://en.wikipedia.org/wiki/MAVLink):

> MAVLink or Micro Air Vehicle Link is a protocol for communicating with small unmanned vehicle. It is designed as a header-only message marshaling library. MAVLink was first released early 2009[1] by Lorenz Meier under LGPL license.[2]

## Usage:

The following swift code:

```swift
let data = "fe33000b16fd014f4f505300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b32f"
let d = NSData(hexString: data)
let buffer:UnsafeBufferPointer <UInt8> = d!.buffer.asUnsafeBufferPointer()
let message = Message(buffer: buffer)!
println("\(message.definition.name): \(message.values)")
```
Produces this output:

```
STATUSTEXT: [text: OOPS, severity: 1]
```

(Which is correct. Honest. Going to have to trust me until I get some unit tests buddy)

## Status

* Supports reading MAVLink messages.
  * Currently only supports arrays of chars (strings), no arrays of number types (yet)
* Validation of MAVLink messages
  * Message header
  * Message length
  * Message CRC (including the "crc extra" calculation)
* Messages are represented as swift Message structs. A Message has a values dictionary property which is used to access message data.
* Fetches the common MAVLink "schema" directly from network - obviously this needs to work offline too: https://raw.githubusercontent.com/mavlink/mavlink/master/message_definitions/v1.0/common.xml
* Does not allow multiple schemas (yet)
* Does not generate swift structs or enums.
* No unit tests
* No construction of messages.
* Beginnings of a Swift serial port class.

## License

BSD 2-Clause: See LICENSE file

## See also:

* https://github.com/mavlink/mavlink
* http://qgroundcontrol.org/mavlink/start
* http://qgroundcontrol.org/mavlink/crc_extra_calculation

