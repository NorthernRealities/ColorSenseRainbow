//
//  RainbowHexStringBuilder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-05-28.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class RainbowHexStringBuilder: ColorBuilder {
    
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
            // User has changed the alpha so we need to add it to the code. We fake a search result to take account for
            // the " that the string has at the end before we append the alpha component.
            
            var replacementString = forSearchResult.capturedStrings[1]
            replacementString += "\", alpha: \(color.alphaComponent)"
            
            
            var fakeTCR : NSTextCheckingResult = forSearchResult.tcr.copy() as! NSTextCheckingResult
            var fakeRange = fakeTCR.rangeAtIndex( 1 )
            fakeRange.length++
            
            var fakeSearchResult : SearchResult = SearchResult ( color: NSColor.africanVioletColor(1.0), textCheckingResult: fakeTCR, capturedStrings: forSearchResult.capturedStrings )

            var rangeToChange = NSMakeRange( forSearchResult.tcr.rangeAtIndex( 1 ).location - forSearchResult.tcr.rangeAtIndex( 0 ).location, forSearchResult.tcr.rangeAtIndex( 1 ).length + 1 )
            
            
            let stringRange = rangeToChange.calculateRangeInString( returnString )
            returnString.replaceRange( stringRange, with: replacementString )
        }
        
        if let modifiedString = processCaptureGroupInSearchResult( forSearchResult, forRangeAtIndex: 1, inText: returnString, withReplacementText: color.asHexString() ) {
            returnString = modifiedString
        } else {
            return nil
        }
        
        return returnString
    }
    

}
