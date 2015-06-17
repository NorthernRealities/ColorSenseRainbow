//
//  DefaultRGBBuilder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-25.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class DefaultRGBBuilder: ColorBuilder {
    
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
        numberFormatter.maximumFractionDigits = ColorBuilder.maximumFractionDigits
        numberFormatter.minimumFractionDigits = 1

        
        if ( forSearchResult.tcr.numberOfRanges == 5 ) {
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 4, inText: returnString, withReplacementText: "\(color.alphaComponent)" ) {
                returnString = modifiedString
            } else {
                return nil
            }
        } else if ( color.alphaComponent < 1.0 ) {
            // User has changed the alpha so we need to add it to the code.
            
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 3, inText: returnString, withReplacementText: forSearchResult.capturedStrings[3] + ", alpha: \(color.alphaComponent)" ) {
                returnString = modifiedString
            } else {
                return nil
            }
        }

        
        if let component = numberFormatter.stringFromNumber( Double ( color.blueComponent ) ) {
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 3, inText: returnString, withReplacementText: component ) {
                returnString = modifiedString
            } else {
                return nil
            }
        } else {
            println ( "Error converting blue component with value of \(color.blueComponent) to a string." )
            return nil
        }

        if let component = numberFormatter.stringFromNumber( Double ( color.greenComponent ) ) {
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 2, inText: returnString, withReplacementText: component ) {
                returnString = modifiedString
            } else {
                return nil
            }
        } else {
            println ( "Error converting green component with value of \(color.greenComponent) to a string." )
            return nil
        }
        
        if let component = numberFormatter.stringFromNumber( Double ( color.redComponent ) ) {
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 1, inText: returnString, withReplacementText: component ) {
                returnString = modifiedString
            } else {
                return nil
            }
        } else {
            println ( "Error converting red component with value of \(color.redComponent) to a string." )
            return nil
        }
        
        
        return returnString
    }

}
