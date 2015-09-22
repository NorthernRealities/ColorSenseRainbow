//
//  RGBFloatSeeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-23.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class RGBFloatSeeker: Seeker {

    override init () {
        super.init()
        
        var error : NSError?
        
        
        // Swift
        // The values 0 and 1 are valid so everything after is optional.  The solution "\\.?[0-9]*" isn't optimal
        // because the period could be specified without any digits after and a match be made or vice versa.
        
    var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*red:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*green:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*blue:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*alpha:\\s*([01]|[01]\\.[0-9]+)\\s*\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift RGB float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            regex = try NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*red:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*green:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*blue:\\s*([01]|[01]\\.[0-9]+)\\s*\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift RGB float without alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            regex = try NSRegularExpression ( pattern: "NSColor\\s*\\(\\s*(?:calibrated|device|SRGB)Red:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*green:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*blue:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*alpha:\\s*([01]|[01]\\.[0-9]+)\\s*\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift NSColor calibrated, device, SRGB float regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        
        do {
            // Objective-C - Only functions with alpha defined

            regex = try NSRegularExpression ( pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWithRed:\\s*([01]|[01]\\.[0-9]+)f?\\s*green:\\s*([01]|[01]\\.[0-9]+)f?\\s*blue:\\s*([01]|[01]\\.[0-9]+)f?\\s*alpha:\\s*([01]|[01]\\.[0-9]+)f?\\s*\\]", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C RGB float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            // Don't care about saving the Calibrated, Device, or SRGB since we assume that any function that
            // replace the values will do so selectively instead of overwriting the whole string.
        
            regex = try NSRegularExpression ( pattern: "\\[\\s*NSColor\\s*colorWith(?:Calibrated|Device|SRGB)Red:\\s*([01]|[01]\\.[0-9]+)f?\\s*green:\\s*([01]|[01]\\.[0-9]+)f?\\s*blue:\\s*([01]|[01]\\.[0-9]+)f?\\s*alpha:\\s*([01]|[01]\\.[0-9]+)f?\\s*\\]", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C calibrated, device, SRGB calculated float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
    }
    
    
    override func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        if ( ( match.numberOfRanges == 4 ) || ( match.numberOfRanges == 5 ) ) {
            var alphaValue : CGFloat = 1.0
            
            let matchString = stringFromRange( match.range, line: line )
            let redString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
            let greenString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
            let blueString = stringFromRange( match.rangeAtIndex( 3 ), line: line )
            var capturedStrings = [ matchString, redString, greenString, blueString ]
            
            if ( match.numberOfRanges == 5 ) {
                let alphaString = stringFromRange( match.rangeAtIndex( 4 ), line: line )
                
                alphaValue = CGFloat ( ( alphaString as NSString).doubleValue )
                capturedStrings.append( alphaString )
            }
            
            
            let redValue = CGFloat ( ( redString as NSString).doubleValue )
            let greenValue = CGFloat ( ( greenString as NSString).doubleValue )
            let blueValue = CGFloat ( ( blueString as NSString).doubleValue )
            
            let color = NSColor ( red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue )
            
            var searchResult = SearchResult ( color: color, textCheckingResult: match, capturedStrings: capturedStrings )
            searchResult.creationType = .DefaultRGB
            
            return searchResult
        }
        
        return nil
    }
}
