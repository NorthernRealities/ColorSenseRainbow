//
//  RainbowHexIntBuilder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-05-27.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class RainbowHexIntBuilder: ColorBuilder {
    
    /**
    Generates a String containing the code required to create a color object for the specified color in the method detailed by the SearchResults.  While a new string could be generated more easily by just entering the values into a template replacing the values in the existing string will keep the formatting the way the user prefers.  This involves moving backwards through the values as the new values may be different lengths and would change the ranges for later values.
    
    - parameter color:            The new color that will be described by the string.
    - parameter forSearchResults: A SearchResults object containing the ranges for text to replace.
    
    - returns: A String object containing code how to create the color.
    */
    
    override func stringForColor( color : NSColor, forSearchResult : SearchResult ) -> String? {
        
        var returnString = ""
        
        if let unwrappedString = forSearchResult.capturedStrings.first {
            returnString = unwrappedString
        } else {
            return nil
        }
        
        
        if ( forSearchResult.tcr.numberOfRanges == 3 ) {
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 2, inText: returnString, withReplacementText: "\(color.alphaComponent)" ) {
                returnString = modifiedString
            } else {
                return nil
            }
        } else if ( color.alphaComponent < 1.0 ) {
            // User has changed the alpha so we need to add it to the code.
            
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 1, inText: returnString, withReplacementText: forSearchResult.capturedStrings[1] + ", alpha: \(color.alphaComponent)" ) {
                returnString = modifiedString
            } else {
                return nil
            }
        }
        
        if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 1, inText: returnString, withReplacementText: color.asHexString() ) {
            returnString = modifiedString
        } else {
            return nil
        }
        
        return returnString
    }
    
    
}
