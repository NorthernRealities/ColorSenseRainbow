//
//  DefaultHSBBuilder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-08-02.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class DefaultHSBBuilder: ColorBuilder {

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
        numberFormatter.decimalSeparator = "."
        
        
        // First thing to do is to convert the color to the Calibrated RGB ColorSpace.
        // It should be but we do the conversion just in case or else it will raise an exception.
        
        if let hueColor = color.colorUsingColorSpace( NSColorSpace.genericRGBColorSpace() ) {
        
            // While it always has an alpha component there may be an extension at a later date that
            // removes it so keep this in there.  It doesn't hurt.
            
            if ( forSearchResult.tcr.numberOfRanges == 5 ) {
                if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 4, inText: returnString, withReplacementText: "\(hueColor.alphaComponent)" ) {
                    returnString = modifiedString
                } else {
                    return nil
                }
            } else if ( hueColor.alphaComponent < 1.0 ) {
                // User has changed the alpha so we need to add it to the code.
                
                if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 3, inText: returnString, withReplacementText: forSearchResult.capturedStrings[3] + ", alpha: \(hueColor.alphaComponent)" ) {
                    returnString = modifiedString
                } else {
                    return nil
                }
            }
            
            
            if let component = numberFormatter.stringFromNumber( Double ( hueColor.brightnessComponent ) ) {
                if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 3, inText: returnString, withReplacementText: component ) {
                    returnString = modifiedString
                } else {
                    return nil
                }
            } else {
                println ( "Error converting brightness component with value of \(hueColor.brightnessComponent) to a string." )
                return nil
            }
            
            if let component = numberFormatter.stringFromNumber( Double ( hueColor.saturationComponent ) ) {
                if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 2, inText: returnString, withReplacementText: component ) {
                    returnString = modifiedString
                } else {
                    return nil
                }
            } else {
                println ( "Error converting saturation component with value of \(hueColor.saturationComponent) to a string." )
                return nil
            }
            
            if let component = numberFormatter.stringFromNumber( Double ( hueColor.hueComponent ) ) {
                if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 1, inText: returnString, withReplacementText: component ) {
                    returnString = modifiedString
                } else {
                    return nil
                }
            } else {
                println ( "Error converting hue component with value of \(hueColor.hueComponent) to a string." )
                return nil
            }
            
            
            return returnString
        }
        
        println ( "Error converting the color to genericRGB colorspace." )
        return nil

    }

}
