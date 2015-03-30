//
//  RegularExpression.swift
//  Sketch
//
//  Created by Jonathan Wight on 8/31/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

import Foundation

public struct RegularExpression {

    public let expression: NSRegularExpression

    public init(_ pattern:String, options:NSRegularExpressionOptions = NSRegularExpressionOptions()) {
        var error:NSError?
        let expression = NSRegularExpression(pattern:pattern, options:options, error:&error)
        assert(error == nil)
        self.expression = expression!
        
    }

    public func match(string:String, options:NSMatchingOptions = NSMatchingOptions()) -> Match? {
        let length = (string as NSString).length
        if let result = expression.firstMatchInString(string, options:options, range:NSMakeRange(0, length)) {
            return Match(string:string, result:result)
        }
        else {
            return nil
        }
    }

    public struct Match: Printable {
        public let string: String
        public let result: NSTextCheckingResult

        init(string:String, result:NSTextCheckingResult) {
            self.string = string
            self.result = result
        }

        public var description: String {
            get {
                return "Match(\(result.numberOfRanges))"
            }
        }

        public var strings:[String?] {
            get {
                let count = result.numberOfRanges
                let groups:[String?] = (0..<count).map() {
                    let range = self.result.rangeAtIndex($0)
                    if range.location == NSNotFound {
                        return nil
                    }
                    else {
                        return (self.string as NSString).substringWithRange(range)
                    }
                }
                return groups
            }
        }

    }
}
