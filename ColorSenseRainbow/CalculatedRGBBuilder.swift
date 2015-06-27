//
//  CalculatedRGBBuilder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-05-01.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class CalculatedRGBBuilder: ColorBuilder {
    // Was called RGBCalculatedBuilder but the plugin didn't work.  Changed the name and it started to work.
    // Is there a number of significant digits in the class name that caused it to be confused with the Seeker?


    /**
    Generates a String containing the code required to create a color object for the specified color in the method detailed by the SearchResults.  While a new string could be generated more easily by just entering the values into a template replacing the values in the existing string will keep the formatting the way the user prefers.  This involves moving backwards through the values as the new values may be different lengths and would change the ranges for later values.
    
    :param: color            The new color that will be described by the string.
    :param: forSearchResults A SearchResults object containing the ranges for text to replace.
    
    :returns: A String object containing code how to create the color.
    */
    
    override func stringForColor( color : NSColor, forSearchResult : SearchResult ) -> String? {
        
        var returnString = ""

        if let unwrappedString = forSearchResult.capturedStrings.first {
            returnString = unwrappedString
        } else {
            return nil
        }
        
        var numberFormatter = NSNumberFormatter()
		numberFormatter.locale = NSLocale(localeIdentifier: "us")
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = 1  // Don't need as many digits here.
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.decimalSeparator = "." // Users, with another locales have "," separating decimals
        
        var stringFormatter = NSNumberFormatter()
		numberFormatter.locale = NSLocale(localeIdentifier: "us")
        stringFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        stringFormatter.decimalSeparator = numberFormatter.decimalSeparator
        
        if ( forSearchResult.tcr.numberOfRanges == 8 ) {
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 7, inText: returnString, withReplacementText: "\(color.alphaComponent)" ) {
                returnString = modifiedString
            } else {
                return nil
            }
        } else if ( color.alphaComponent < 1.0 ) {
            // User has changed the alpha so we need to add it to the code.
            
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 6, inText: returnString, withReplacementText: forSearchResult.capturedStrings[6] + ", alpha: \(color.alphaComponent)" ) {
                returnString = modifiedString
            } else {
                return nil
            }
        }
        
        
        if let denomString = stringFormatter.numberFromString( forSearchResult.capturedStrings[ 6 ] ) {
            let denom = denomString.doubleValue
            if let component = numberFormatter.stringFromNumber( Double ( color.blueComponent ) * denom ) {
                if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 5, inText: returnString, withReplacementText: component ) {
                    returnString = modifiedString
                } else {
                    return nil
                }
            } else {
                println ( "Error converting color blue component of \(color.blueComponent) to a string." )
                return nil
            }
        } else {
            println ( "Error converting denominator for blue value to a number.  Value is: \(forSearchResult.capturedStrings[ 6 ])" )
            return nil
        }
        
        
        if let denomString = stringFormatter.numberFromString( forSearchResult.capturedStrings[ 4 ] ) {
            let denom = denomString.doubleValue
            if let component = numberFormatter.stringFromNumber( Double ( color.greenComponent ) * denom ) {
                if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 3, inText: returnString, withReplacementText: component ) {
                    returnString = modifiedString
                } else {
                    return nil
                }
            } else {
                println ( "Error converting color green component of \(color.greenComponent) to a string." )
                return nil
            }
        } else {
            println ( "Error converting denominator for green value to a number.  Value is: \(forSearchResult.capturedStrings[ 4 ])" )
            return nil
        }
        
        
        if let denomString = stringFormatter.numberFromString( forSearchResult.capturedStrings[ 2 ] ) {
            let denom = denomString.doubleValue
            if let component = numberFormatter.stringFromNumber( Double ( color.redComponent ) * denom ) {
                if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 1, inText: returnString, withReplacementText: component ) {
                    returnString = modifiedString
                } else {
                    return nil
                }
            } else {
                println ( "Error converting color red component of \(color.redComponent) to a string." )
                return nil
            }
        } else {
            println ( "Error converting denominator for red value to a number.  Value is: \(forSearchResult.capturedStrings[ 2 ])" )
            return nil
        }
        
        return returnString
    }
}
