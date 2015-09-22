//
//  WhiteSeeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-08-05.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class WhiteSeeker: Seeker {
    
    override init () {
        super.init()
        
        var error : NSError?
        
        
        // Swift
        // The values 0 and 1 are valid so everything after is optional.  The solution "\\.?[0-9]*" isn't optimal
        // because the period could be specified without any digits after and a match be made or vice versa.
        
    var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*white:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*alpha:\\s*([01]|[01]\\.[0-9]+)\\s*\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift White float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            // Not used but kept here in case I create an extension that provides a default for the alpha.
        
    //        regex = NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*white:\\s*([01]|[01]\\.[0-9]+)\\s*\\)", options: .allZeros, error: &error )
    //        
    //        if regex == nil {
    //            println ( "Error creating Swift White float without alpha regex = \(error?.localizedDescription)" )
    //        } else {
    //            regexes.append( regex! )
    //        }
        
            
            regex = try NSRegularExpression ( pattern: "NSColor\\s*\\(\\s*(?:calibrated|device|genericGamma22)White:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*alpha:\\s*([01]|[01]\\.[0-9]+)\\s*\\)", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift NSColor calibrated, device, genericGamma22 white float regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        
        do {
            // Objective-C - Only functions with alpha defined
        
            regex = try NSRegularExpression ( pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWithWhite:\\s*([01]|[01]\\.[0-9]+)f?\\s*alpha:\\s*([01]|[01]\\.[0-9]+)f?\\s*\\]", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C White float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            // Don't care about saving the Calibrated, Device, or genericGamma22 since we assume that any function that
            // replace the values will do so selectively instead of overwriting the whole string.
        
            regex = try NSRegularExpression ( pattern: "\\[\\s*NSColor\\s*colorWith(?:Calibrated|Device|GenericGamma22)White:\\s*([01]|[01]\\.[0-9]+)f?\\s*alpha:\\s*([01]|[01]\\.[0-9]+)f?\\s*\\]", options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C calibrated, device, genericGamma22 white float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
    }
    
    
    override func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        // We'll always have two matches right now but if ever the alpha becomes optional
        // then it will be either one or two and this function will have to look like
        // the others.
        
        if ( match.numberOfRanges == 3 ) {
            
            let matchString = stringFromRange( match.range, line: line )
            let whiteString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
            let alphaString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
            let capturedStrings = [ matchString, whiteString, alphaString ]
            
            
            let whiteValue = CGFloat ( ( whiteString as NSString).doubleValue )
            let alphaValue = CGFloat ( ( alphaString as NSString).doubleValue )
            
            let whiteColor = NSColor ( calibratedWhite: whiteValue, alpha: alphaValue )
            if let color = whiteColor.colorUsingColorSpace( NSColorSpace.genericRGBColorSpace() ) {
            
                var searchResult = SearchResult ( color: color, textCheckingResult: match, capturedStrings: capturedStrings )
                searchResult.creationType = .DefaultWhite
                
                return searchResult
            }
        }
        
        return nil
    }
}
