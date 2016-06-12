//
//  RGBCalculatedSeeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-23.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class RGBCalculatedSeeker: Seeker {

    override init () {
        super.init()
        
        var error : NSError?
    
        var regex: NSRegularExpression?
    
        
        // Defines how the RGB component of the colour is specified for numbers >= zero. Numbers may be integer or floating point and intended to be between 0 and 255 inclusive but no bounds checking is performed.
        // Valid values: 0; 0.0; 255; 127.55
        
        let swiftRBGComponentConst = "([0-9]+|[0-9]+\\.[0-9]+)"


        // Defines how the RGB component of the colour is specified for numbers >= zero. Numbers may be integer or floating point and intended to be between 0 and 255 inclusive but no bounds checking is performed.
        // The f is outside of the capture group so that converting the string to a number in the Builder will work.
        // Valid values: 0; 0.0; 255; 127.55, 0.0f 0.f 134.0 154.f 39.0f
        
        let objcRBGComponentConst = "([0-9]+|[0-9]+\\.[0-9]+)(?:f|\\.f)?"

        
        // Swift
    
        let commonSwiftRegex = "ed:\\s*" + swiftRBGComponentConst + "\\s*\\/\\s*" + swiftRBGComponentConst + "\\s*,\\s*green:\\s*" + swiftRBGComponentConst + "\\s*\\/\\s*" + swiftRBGComponentConst + "\\s*,\\s*blue:\\s*" + swiftRBGComponentConst + "\\s*\\/\\s*" + swiftRBGComponentConst + "\\s*"
    
        do {
            regex = try NSRegularExpression ( pattern: "(?:NS|UI)Color" + swiftInit + "\\s*\\(\\s*r" + commonSwiftRegex + ",\\s*alpha:\\s*" + swiftAlphaConst + "\\s*\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift RGB calculated float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            regex = try NSRegularExpression ( pattern: "(?:NS|UI)Color" + swiftInit + "\\s*\\(\\s*r" + commonSwiftRegex + "\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift RGB calculated float without alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            regex = try NSRegularExpression ( pattern: "NSColor" + swiftInit + "\\s*\\(\\s*(?:calibrated|device|SRGB)R" + commonSwiftRegex + ",\\s*alpha:\\s*" + swiftAlphaConst + "\\s*\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift NSColor calibrated, device, SRGB calculated float regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        // Objective-C - Only functions with alpha defined

        let commonObjCRegex = "Red:\\s*" + objcRBGComponentConst + "\\s*\\/\\s*" + objcRBGComponentConst + "\\s*green:\\s*" + objcRBGComponentConst + "\\s*\\/\\s*" + objcRBGComponentConst + "\\s*blue:\\s*" + objcRBGComponentConst + "\\s*\\/\\s*" + objcRBGComponentConst + "\\s*alpha:\\s*" + objcAlphaConst + "\\s*\\]"
        
        do {
            regex = try NSRegularExpression ( pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWith" + commonObjCRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C RGB calculated float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            // Don't care about saving the Calibrated, Device, or SRGB since we assume that any function that 
            // replace the values will do so selectively instead of overwriting the whole string.
        
            regex = try NSRegularExpression ( pattern: "\\[\\s*NSColor\\s*colorWith(?:Calibrated|Device|SRGB)" + commonObjCRegex, options: [])
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
        
        if ( ( match.numberOfRanges == 7 ) || ( match.numberOfRanges == 8 ) ) {
            var alphaValue : CGFloat = 1.0
            
            let matchString = stringFromRange( match.range, line: line )
            let redNomString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
            let redDenomString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
            let greenNomString = stringFromRange( match.rangeAtIndex( 3 ), line: line )
            let greenDenomString = stringFromRange( match.rangeAtIndex( 4 ), line: line )
            let blueNomString = stringFromRange( match.rangeAtIndex( 5 ), line: line )
            let blueDenomString = stringFromRange( match.rangeAtIndex( 6 ), line: line )
            var capturedStrings = [ matchString, redNomString, redDenomString, greenNomString, greenDenomString, blueNomString, blueDenomString ]
            
            if ( match.numberOfRanges == 8 ) {
                let alphaString = stringFromRange( match.rangeAtIndex( 7 ), line: line )
                
                alphaValue = CGFloat ( ( alphaString as NSString).doubleValue )
                capturedStrings.append( alphaString )
            }
            
            
            let redValue = CGFloat ( ( ( redNomString as NSString).doubleValue ) / ( ( redDenomString as NSString ).doubleValue ) )
            let greenValue = CGFloat ( ( ( greenNomString as NSString).doubleValue ) / ( ( greenDenomString as NSString ).doubleValue ) )
            let blueValue = CGFloat ( ( ( blueNomString as NSString).doubleValue ) / ( ( blueDenomString as NSString ).doubleValue ) )
            
            let color = NSColor ( red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue )
            
            var searchResult = SearchResult ( color: color, textCheckingResult: match, capturedStrings: capturedStrings )
            searchResult.creationType = .RGBCalculated
            
            return searchResult
        }
        
        return nil
    }
}
