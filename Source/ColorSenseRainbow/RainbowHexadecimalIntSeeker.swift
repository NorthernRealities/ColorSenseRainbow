//
//  RainbowHexadecimalIntSeeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-23.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class RainbowHexadecimalIntSeeker: Seeker {

    override init () {
        super.init()
        
        var error : NSError?
        
        
        var regex = NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*hex:\\s*0x([0-9a-fA-F]{6})\\s*,\\s*alpha:\\s*([01]\\.?[0-9]*)\\s*\\)", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Swift Rainbow hexidecimal int with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        regex = NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*hex:\\s*0x([0-9a-fA-F]{6})\\s*\\)", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Swift Rainbow hexidecimal int without alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
    }
    
    
    override func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        if ( ( match.numberOfRanges == 2 ) || ( match.numberOfRanges == 3 ) ) {
            var alphaValue : CGFloat = 1.0
            
            let matchString = stringFromRange( match.range, line: line )
            let hexString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
            var capturedStrings = [ matchString, hexString ]
            
            if ( match.numberOfRanges == 3 ) {
                let alphaString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
                alphaValue = CGFloat ( (alphaString as NSString).doubleValue )
                capturedStrings.append( alphaString )
            }
            
            
            var color = NSColor ( hexString: hexString )
            
            if ( alphaValue != 1.0 ) {
                color = color.colorWithAlphaComponent( alphaValue )
            }
            
            var searchResult = SearchResult ( color: color, textCheckingResult: match, capturedStrings: capturedStrings )
            searchResult.creationType = .RainbowHexInt
            
            return searchResult
        }
        
        return nil
    }
}
