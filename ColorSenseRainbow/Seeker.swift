//
//  Seeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-19.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class Seeker {

    var regexes : [NSRegularExpression] = []
    
    
    /**
    Look for an object of color being created in the line of text being passed in using regular expressions.  If found it returns back an object of NSColor and the location in the line where the text occurs.
    
    :param: line      The text to search for a color being created.
    :param: lineRange Where in the line the caret of the NSTextView is placed.
    
    :returns: A SearchResult object containing a NSColor and a NSRange if a match is found.
    */
    
    func searchForColor ( line : String, selectedRange : NSRange ) -> SearchResult? {

        for regex in ( regexes ) {
            let range = NSMakeRange( 0, count ( line ) )

            let matches = regex.matchesInString( line, options: .allZeros, range: range ) as! [NSTextCheckingResult]
            if ( matches.count > 0 ) {
                for match in matches {
                    if ( self.matchRangeContainsLineRange( match.range, selectedRange: selectedRange ) == true ) {
                        if let searchResult = processMatch( match, line: line ) {
                            return searchResult
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    
    /**
    Determines whether or not that the caret (as specified by the selectedRange) is within the text found to create a color object.
    
    :param: matchRange     The range of text that creates a color object.
    :param: selectedRange  The location of the caret on the line (should have a length of 0).
    
    :returns: A Bool value.
    */
    
    func matchRangeContainsLineRange ( matchRange : NSRange, selectedRange : NSRange ) -> Bool {
    
        // TODO: - Create test that has two colors created on a line and see that the right one is selected.
        return ( ( selectedRange.location >= matchRange.location ) &&
                 ( NSMaxRange( selectedRange ) <= NSMaxRange( matchRange ) ) )
    }
    
    
    /**
    An abstract function that should be overridden by the child class.  The purpose of the function is to take a match and create the color that was found.
    
    :param: match A NSTextCheckingResult that provides the details where the color text is within the line.
    :param: line  A String containing the line of text.
    
    :returns: If the color can be created then a SearchResult is returned, otherwise nil.
    */
    
    func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        return nil
    }
    
    
    /**
    Returns a substring from the String passed in as defined by the given NSRange.  It translates the NSRange into values useful to Range<String.Index> instead of converting the String object to an NSString object.  No checking is performed to ensure that the range is valid.
    
    :param: range The NSRange specifying the substring to grab.
    :param: line  The String containing the text to take the substring from.
    
    :returns: A String object
    */
    
    func stringFromRange ( range : NSRange, line : String ) -> String {
        
        return line.substringWithRange( range.calculateRangeInString( line ) )

    }
    
    
    /**
    Converts the String to an enumerated value for the type of color object (UIColor or NSColor).  If the String is equal to "UI" then the associated value is returned otherwise the value for "NS" is sent back.
    
    :param: colorTypeString The String object to test.
    
    :returns: A CSRColorType enumerated value.
    */
    
    func colorTypeFromString ( colorTypeString : String ) -> CSRColorType {
        
        switch colorTypeString {
        case "UI":
            return .UIColor

        case "NS":
            fallthrough
            
        default:
            return .NSColor
        }
    }
    
    
    /**
    Determines whether the string passed in contains Swift or Objective-C code.  If it contains an "[" then Objective-C code is assumed, otherwise it is assumed that the string contains Swift code.  No checking is performed to determined if the string contains valid code of either language.
    
    :param: stringToCheck The String object containing the code to test.
    
    :returns: A CSRProgrammingLanguage enum value specifying the language.
    */
    
    func programmingLanguageFromString ( stringToCheck : String ) -> CSRProgrammingLanguage {
        
        if ( stringToCheck.rangeOfString( "[" ) != nil ) {
            return .ObjectiveC
        }
        
        return .Swift
    }
}
