//
//  RainbowHSBSeeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2016-04-04.
//  Copyright © 2016 Northern Realities Inc. All rights reserved.
//

import AppKit

class RainbowHSBSeeker: Seeker {
    
    override init () {
        super.init()
        
        
        var error : NSError?
        
        var regex: NSRegularExpression?
        
        
        // Swift
        
        let commonSwiftRegex = "(?:NS|UI)Color" + swiftInit + "\\s*\\(\\s*hueDegrees:\\s*" + swiftHSBComponentConst + "\\s*,\\s*saturationPercent:\\s*" + swiftHSBComponentConst + "\\s*,\\s*brightnessPercent:\\s*" + swiftHSBComponentConst + "\\s*"
        
        do {
            regex = try NSRegularExpression ( pattern: commonSwiftRegex + ",\\s*alpha:\\s*" + swiftAlphaConst + "\\s*\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift Rainbow hexidecimal int with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            regex = try NSRegularExpression ( pattern: commonSwiftRegex + "\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift Rainbow hexidecimal int without alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
    }
    
    
    override func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        if ( ( match.numberOfRanges == 4 ) || ( match.numberOfRanges == 5 ) ) {
            var alphaValue : CGFloat = 1.0
            
            let matchString = stringFromRange( match.range, line: line )
            let hueDegreesString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
            let saturationPercentString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
            let brightnessPercentString = stringFromRange( match.rangeAtIndex( 3 ), line: line )
            var capturedStrings = [ matchString, hueDegreesString, saturationPercentString, brightnessPercentString ]
            
            if ( match.numberOfRanges == 5 ) {
                let alphaString = stringFromRange( match.rangeAtIndex( 4 ), line: line )
                
                alphaValue = CGFloat ( ( alphaString as NSString).doubleValue )
                capturedStrings.append( alphaString )
            }
            
            
            let hueValue = ( hueDegreesString as NSString).integerValue
            let saturationValue = ( saturationPercentString as NSString).integerValue
            let brightnessValue = ( brightnessPercentString as NSString).integerValue
            
            let hueColor = NSColor ( hueDegrees: hueValue, saturationPercent: saturationValue, brightnessPercent: brightnessValue, alpha: alphaValue )
            
            if let rgbColor = hueColor.colorUsingColorSpace( NSColorSpace.genericRGBColorSpace() ) {
                // If not converted to RGB ColorSpace then the plugin would crash later on.
                
                var searchResult = SearchResult ( color: rgbColor, textCheckingResult: match, capturedStrings: capturedStrings )
                searchResult.creationType = .RainbowHSB
                
                return searchResult
            }
        }
        
        return nil
    }
}
