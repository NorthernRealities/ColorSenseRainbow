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
        
        
        // Swift
        
        var regex = NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*red:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*,\\s*green:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*,\\s*blue:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*,\\s*alpha:\\s*([01]\\.[0-9]+)\\s*\\)", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Swift RGB calculated float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        regex = NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*red:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*,\\s*green:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*,\\s*blue:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*\\)", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Swift RGB calculated float without alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        regex = NSRegularExpression ( pattern: "NSColor\\s*\\(\\s*(?:calibrated|device|SRGB)Red:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*,\\s*green:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*,\\s*blue:\\s*([0-9]+\\.?[0-9]*)\\s*\\/\\s*([0-9]+\\.?[0-9]*)\\s*,\\s*alpha:\\s*([01]\\.[0-9]+)\\s*\\)", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Swift NSColor calibrated, device, SRGB calculated float regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        // Objective-C - Only functions with alpha defined
        // The f? is outside of the capture group so that converting the string to a number in the Builder will work.

        regex = NSRegularExpression ( pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWithRed:\\s*([0-9]+\\.?[0-9]*)f?\\s*\\/\\s*([0-9]+\\.?[0-9]*)f?\\s*green:\\s*([0-9]+\\.?[0-9]*)f?\\s*\\/\\s*([0-9]+\\.?[0-9]*)f?\\s*blue:\\s*([0-9]+\\.?[0-9]*)f?\\s*\\/\\s*([0-9]+\\.?[0-9]*)f?\\s*alpha:\\s*([01]\\.[0-9]+)f?\\s*\\]", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Objective-C RGB calculated float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        // Don't care about saving the Calibrated, Device, or SRGB since we assume that any function that 
        // replace the values will do so selectively instead of overwriting the whole string.
        
        regex = NSRegularExpression ( pattern: "\\[\\s*NSColor\\s*colorWith(?:Calibrated|Device|SRGB)Red:\\s*([0-9]+\\.?[0-9]*)f?\\s*\\/\\s*([0-9]+\\.?[0-9]*)f?\\s*green:\\s*([0-9]+\\.?[0-9]*)f?\\s*\\/\\s*([0-9]+\\.?[0-9]*)f?\\s*blue:\\s*([0-9]+\\.?[0-9]*)f?\\s*\\/\\s*([0-9]+\\.?[0-9]*)f?\\s*alpha:\\s*([01]\\.[0-9]+)f?\\s*\\]", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Objective-C calibrated, device, SRGB calculated float with alpha regex = \(error?.localizedDescription)" )
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
