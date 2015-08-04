//
//  SearchResult.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-19.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

enum CSRColorCreationType {
    case Unknown
    case RGBCalculated      // RGB where values are n/255
    case PredefinedColor    // A named colour such as blackColor and is known by NSColor
    case RainbowHexInt      // Using the Rainbow convenience method of a hexadecimal integer
    case RainbowHexString   // Using the Rainbow convenience method of a hexadecimal string
    case RainbowInt         // Rainbow convenience method using integers
    case DefaultHSB         // HSB with floating point values between 0 and 1
    case DefaultRGB         // RGB with floating point values between 0 and 1
}


enum CSRColorType {
    case Unknown
    case NSColor
    case UIColor
}


enum CSRProgrammingLanguage {
    case Unknown
    case Swift
    case ObjectiveC
}


struct SearchResult : Printable {
    var creationType : CSRColorCreationType
    var colorType : CSRColorType
    var language : CSRProgrammingLanguage
    var color : NSColor!
    var tcr : NSTextCheckingResult!
    var rangeInTextView : NSRange!
    var capturedStrings : [String] = []
    
    var description : String {
        return "Search Result: \(color) - \(tcr.range)"
    }
    
    
    init ( color : NSColor, textCheckingResult : NSTextCheckingResult, capturedStrings : [String] ) {
        
        self.color = color
        self.tcr = textCheckingResult
        self.capturedStrings = capturedStrings
        self.creationType = .Unknown
        self.language = .Unknown
        self.colorType = .Unknown
    }
}