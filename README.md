# SwiftMavLink

## Introduction

Pure Swift implementation of the MAVLink unmanned vehicle communication protocol

From [Wikipedia](https://en.wikipedia.org/wiki/MAVLink):

> MAVLink or Micro Air Vehicle Link is a protocol for communicating with small unmanned vehicle. It is designed as a header-only message marshaling library. MAVLink was first released early 2009[1] by Lorenz Meier under LGPL license.[2]

## Status

* Supports reading MAVLink messages.
  * Currently only supports uint8, uint32 and arrays of chars (strings).
    * Other integer, float, double and arrays of integers/floats coming soon.
* Validation of MAVLink messages
  * Message header
  * Message length
  * Message CRC (including the "crc extra" calculation)
* Messages are represented as a swift Message structs. A Message has a values dictionary property which is used to access message data.
* Fetches the common MAVLink "schema" directly from network - obviously this needs to be work offline too: https://raw.githubusercontent.com/mavlink/mavlink/master/message_definitions/v1.0/common.xml
* Does not allow multiple schemas (yet)
* Does not generate swift structs or enums.
* No unit tests
* Not tested against many message types yet
* No construction of messages.

## License

BSD 2-Clause: See LICENSE file

## See also:

* https://github.com/mavlink/mavlink
* http://qgroundcontrol.org/mavlink/start
* http://qgroundcontrol.org/mavlink/crc_extra_calculation

