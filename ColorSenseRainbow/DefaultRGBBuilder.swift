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
    
    - parameter color:            The new color that will be described by the string.
    - parameter forSearchResults: A SearchResults object containing the ranges for text to replace.
    
    - returns: A String object containing code how to create the color.
    */
    
    override func stringForColor( color : NSColor, forSearchResult : SearchResult ) -> String? {
        
        guard var returnString = forSearchResult.capturedStrings.first else {
            return nil
        }
        
        
        let numberFormatter = NSNumberFormatter()
		numberFormatter.locale = NSLocale(localeIdentifier: "us")

        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = ColorBuilder.maximumAlphaFractionDigits
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.decimalSeparator = "."

        
        // While the alpha component may not always be used it most likely will be as
        // only add-on library functions don't have it. So to reduce code duplication
        // with minimal performance impact I've just put the conversion here.
        
        guard let alphaComponent = convertNumberToString( Double ( color.alphaComponent ), numberDesc: "alpha component", numberFormatter: numberFormatter ) else {
            return nil
        }
        
        
        if ( forSearchResult.tcr.numberOfRanges == 5 ) {
            
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 4, inText: returnString, withReplacementText: alphaComponent ) {
                returnString = modifiedString
            } else {
                return nil
            }
        } else if ( color.alphaComponent < 1.0 ) {
            // User has changed the alpha from using using a function that assumed the default of 1.0 so we need to add it to the code.
            
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 3, inText: returnString, withReplacementText: forSearchResult.capturedStrings[3] + ", alpha: " + alphaComponent ) {
                returnString = modifiedString
            } else {
                return nil
            }
        }


        // Change the maximun number of digits for the colour components and then handle the colours.
        
        numberFormatter.maximumFractionDigits = ColorBuilder.maximumColorFractionDigits

        
        guard
            let blueComponent = convertNumberToString( Double ( color.blueComponent ), numberDesc: "blue component", numberFormatter: numberFormatter ),
            let greenComponent = convertNumberToString( Double ( color.greenComponent ), numberDesc: "green component", numberFormatter: numberFormatter ),
            let redComponent = convertNumberToString( Double ( color.redComponent ), numberDesc: "red component", numberFormatter: numberFormatter ) else {
                
            return nil
        }

        
        // Easier to use if statements than guard. Would have to use different
        // variable names with guard and couldn't put them all together like
        // the colour conversion as you need the output of one as input to
        // the next.
        
        if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 3, inText: returnString, withReplacementText: blueComponent ) {
            returnString = modifiedString
        } else {
            return nil
        }

        
        if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 2, inText: returnString, withReplacementText: greenComponent ) {
            returnString = modifiedString
        } else {
            return nil
        }
        
        
        if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 1, inText: returnString, withReplacementText: redComponent ) {
            returnString = modifiedString
        } else {
            return nil
        }
        
        
        return returnString
    }

}
