//
//  HSBFloatSeeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-08-02.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class HSBFloatSeeker: Seeker {
    
    override init () {
        super.init()
        
        var error : NSError?
        
        var regex: NSRegularExpression?
        
        // Swift

        let commonSwiftRegex = "ue:\\s*" + swiftFloatColourConst + "\\s*,\\s*saturation:\\s*" + swiftFloatColourConst + "\\s*,\\s*brightness:\\s*" + swiftFloatColourConst + "\\s*,\\s*alpha:\\s*" + swiftAlphaConst + "\\s*\\)"
        
        do {
            regex = try NSRegularExpression ( pattern: "(?:NS|UI)Color" + swiftInit + "\\s*\\(\\s*h" + commonSwiftRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift HSB float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        
        do {
            regex = try NSRegularExpression ( pattern: "NSColor" + swiftInit + "\\s*\\(\\s*(?:calibrated|device)H" + commonSwiftRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift NSColor calibrated, device HSB float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        
        // Objective-C - Only functions with alpha defined

        let commonObjCRegex = "Hue:\\s*" + objcFloatColourConst + "\\s*saturation:\\s*" + objcFloatColourConst + "\\s*brightness:\\s*" + objcFloatColourConst + "\\s*alpha:\\s*" + objcAlphaConst + "\\s*\\]"
        
        do {
            regex = try NSRegularExpression ( pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWith" + commonObjCRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C HSB float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            // Don't care about saving the Calibrated or Device since we assume that any function that
            // replace the values will do so selectively instead of overwriting the whole string.
        
            regex = try NSRegularExpression ( pattern: "\\[\\s*NSColor\\s*colorWith(?:Calibrated|Device)" + commonObjCRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C calibrated, device HSB calculated float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
    }
    
    
    override func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        if ( ( match.numberOfRanges == 4 ) || ( match.numberOfRanges == 5 ) ) {
            var alphaValue : CGFloat = 1.0
            
            let matchString = stringFromRange( match.range, line: line )
            let hueString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
            let saturationString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
            let brightnessString = stringFromRange( match.rangeAtIndex( 3 ), line: line )
            var capturedStrings = [ matchString, hueString, saturationString, brightnessString ]
            
            if ( match.numberOfRanges == 5 ) {
                let alphaString = stringFromRange( match.rangeAtIndex( 4 ), line: line )
                
                alphaValue = CGFloat ( ( alphaString as NSString).doubleValue )
                capturedStrings.append( alphaString )
            }
            
            
            let hueValue = CGFloat ( ( hueString as NSString).doubleValue )
            let saturationValue = CGFloat ( ( saturationString as NSString).doubleValue )
            let brightnessValue = CGFloat ( ( brightnessString as NSString).doubleValue )
            
            let hueColor = NSColor ( calibratedHue: hueValue, saturation: saturationValue, brightness: brightnessValue, alpha: alphaValue )
            
            if let rgbColor = hueColor.colorUsingColorSpace( NSColorSpace.genericRGBColorSpace() ) {
                // If not converted to RGB ColorSpace then the plugin would crash later on.
            
                var searchResult = SearchResult ( color: rgbColor, textCheckingResult: match, capturedStrings: capturedStrings )
                searchResult.creationType = .DefaultHSB
                
                return searchResult
            }
        }
        
        return nil
    }
}
