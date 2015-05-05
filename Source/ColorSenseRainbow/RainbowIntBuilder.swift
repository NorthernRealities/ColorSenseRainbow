//
//  RainbowIntBuilder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-28.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class RainbowIntBuilder: ColorBuilder {
    
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
        
        if ( forSearchResult.tcr.numberOfRanges == 5 ) {
            if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 4, inText: returnString, withReplacementText: "\(color.alphaComponent)" ) {
                returnString = modifiedString
            } else {
                return nil
            }
        }
        
        var component = Int ( round ( color.blueComponent * 255 ) )
        if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 3, inText: returnString, withReplacementText: "\(component)" ) {
            returnString = modifiedString
        } else {
            return nil
        }

        component = Int ( round ( color.greenComponent * 255 ) )
        if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 2, inText: returnString, withReplacementText: "\(component)" ) {
            returnString = modifiedString
        } else {
            return nil
        }

        component = Int ( round ( color.redComponent * 255 ) )
        if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 1, inText: returnString, withReplacementText: "\(component)" ) {
            returnString = modifiedString
        } else {
            return nil
        }

        return returnString
    }


}
