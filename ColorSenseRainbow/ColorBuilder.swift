//
//  ColorBuilder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-25.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class ColorBuilder {
    
    static let maximumFractionDigits : Int = 4

    
    /**
    Generates a String containing the code required to create a color object for the specified color in the method detailed by the SearchResults.  While a new string could be generated more easily by just entering the values into a template replacing the values in the existing string will keep the formatting the way the user prefers.  This involves moving backwards through the values as the new values may be different lengths and would change the ranges for later values.  This function should be overridden by child classes.
    
    - parameter color:            The new color that will be described by the string.
    - parameter forSearchResults: A SearchResults object containing the ranges for text to replace.
    
    - returns: A String object containing code how to create the color.
    */
    
    func stringForColor ( color : NSColor, forSearchResult : SearchResult ) -> String? {
        
        return nil
    }
  

    /**
    Returns a String object that has been modified by replacing the specified capture group with the given text.
    
    - parameter sr:                  A SearchResult object that contains the capture group which defines the range of the text that will be replaced.
    - parameter forRangeAtIndex:     An Int value to indicate which range stored in the SearchResult is to be used.
    - parameter inText:              The String in which the replacement will take place.
    - parameter withReplacementText: A String that is the text to be inserting into inText.
    
    - returns: A String object.
    */
    
    func processCaptureGroupInSearchResult ( sr : SearchResult, forRangeAtIndex : Int, inText : String, withReplacementText : String ) -> String? {
        
        var returnString = inText
        
        if let range = offsetRangeInSearchResult( sr, forRangeAtIndex: forRangeAtIndex ) {
        
            let stringRange = range.calculateRangeInString( returnString )
            returnString.replaceRange( stringRange, with: withReplacementText )
            
            return returnString
        }
        
        return nil
    }

    
    /**
    Creates an NSRange object that is the offset from the start of the match to the start of the capture group found at the range at the given index.  The range at index zero is the whole match.
    
    - parameter searchResult:    A SearchResult object which contains a NSTextCheckingResult that holds the NSRanges that will be used to perform the calculations.
    - parameter forRangeAtIndex: An Int specifying which capture group to calculate the offset of.
    
    - returns: An NSRange object if an offset can be calculated, nil otherwise.
    */
    
    func offsetRangeInSearchResult ( searchResult : SearchResult, forRangeAtIndex: Int ) -> NSRange? {
        
        if ( ( forRangeAtIndex >= 0 ) && ( forRangeAtIndex < searchResult.tcr.numberOfRanges ) ) {
            return NSMakeRange( searchResult.tcr.rangeAtIndex( forRangeAtIndex ).location - searchResult.tcr.rangeAtIndex( 0 ).location, searchResult.tcr.rangeAtIndex( forRangeAtIndex ).length )
        }
        
        return nil
    }

}
