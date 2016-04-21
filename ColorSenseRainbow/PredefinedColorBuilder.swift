//
//  PredefinedColorBuilder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-29.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import Cocoa

class PredefinedColorBuilder: ColorBuilder {

    /**
    Generates a String containing the code required to create a color object for the specified color in the method detailed by the SearchResults.  While a new string could be generated more easily by just entering the values into a template replacing the values in the existing string will keep the formatting the way the user prefers.  This involves moving backwards through the values as the new values may be different lengths and would change the ranges for later values.
    
    - parameter color:            The new color that will be described by the string.
    - parameter forSearchResults: A SearchResults object containing the ranges for text to replace.
    
    - returns: A String object containing code how to create the color.
    */
    
    override func stringForColor( color : NSColor, forSearchResult : SearchResult ) -> String? {
        
        // This method is different than the others because it creates a brand new color instead of just
        // replacing values.  In the future maybe write a function that looks up the components of the color
        // and see if there is a corresponding predefined color.  The trick will be seeing if the user moves
        // a predefined color to one that isn't and then one that is.  How to tell that they originally started 
        // from a predefined color since you don't want to overwrite a different type of color creation.
        

        if ( forSearchResult.colorType == .Unknown ) || ( forSearchResult.language == .Unknown ) {
            return nil
        }
        

        return forSearchResult.language == .ObjectiveC ? createObjCColor( color, forSearchResult: forSearchResult ) : createSwiftColor( color, forSearchResult: forSearchResult )
    }

    
    private func createSwiftColor ( color : NSColor, forSearchResult : SearchResult ) -> String? {
        
        let numberFormatter = NSNumberFormatter()
		numberFormatter.locale = NSLocale(localeIdentifier: "us")

        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = ColorBuilder.maximumColorFractionDigits
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.decimalSeparator = "."
        
        var returnString = colorStringForType( forSearchResult.colorType )
        returnString += "Color ( red: "
        if let modifiedString = numberFormatter.stringFromNumber( Double ( color.redComponent ) ) {
            returnString += modifiedString
        } else {
            print ( "Error converting red component \(color.redComponent) of color to a string" )
            return nil
        }

        
        returnString += ", green: "
        if let modifiedString = numberFormatter.stringFromNumber( Double ( color.greenComponent ) ) {
            returnString += modifiedString
        } else {
            print ( "Error converting green component \(color.greenComponent) of color to a string" )
            return nil
        }
        
        
        returnString += ", blue: "
        if let modifiedString = numberFormatter.stringFromNumber( Double ( color.blueComponent ) ) {
            returnString += modifiedString
        } else {
            print ( "Error converting blue component \(color.blueComponent) of color to a string" )
            return nil
        }

        
        // Always include the alpha component as it is impossible to tell if there is
        // an extionsion to handle the creation of colours without it.
        
        numberFormatter.maximumFractionDigits = ColorBuilder.maximumAlphaFractionDigits

        if let modifiedString = numberFormatter.stringFromNumber( Double ( color.alphaComponent ) ) {
            returnString += ", alpha: \(modifiedString) )"
        } else {
            print ( "Error converting alpha component \(color.alphaComponent) of color to a string" )
            return nil
        }
        
        return returnString
    }

    
    private func createObjCColor ( color : NSColor, forSearchResult : SearchResult ) -> String? {

        let numberFormatter = NSNumberFormatter()
		numberFormatter.locale = NSLocale(localeIdentifier: "us")

        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = ColorBuilder.maximumColorFractionDigits
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.decimalSeparator = "."
        
        var returnString = "["
        returnString += colorStringForType( forSearchResult.colorType )
        returnString += "Color colorWithRed:"
        if let modifiedString = numberFormatter.stringFromNumber( Double ( color.redComponent ) ) {
            returnString += modifiedString
        } else {
            print ( "Error converting red component \(color.redComponent) of color to a string" )
            return nil
        }
        
        returnString += " green:"
        if let modifiedString = numberFormatter.stringFromNumber( Double ( color.greenComponent ) ) {
            returnString += modifiedString
        } else {
            print ( "Error converting green component \(color.greenComponent) of color to a string" )
            return nil
        }
        
        returnString += " blue:"
        if let modifiedString = numberFormatter.stringFromNumber( Double ( color.blueComponent ) ) {
            returnString += modifiedString
        } else {
            print ( "Error converting blue component \(color.blueComponent) of color to a string" )
            return nil
        }
        
        
        numberFormatter.maximumFractionDigits = ColorBuilder.maximumAlphaFractionDigits

        if let modifiedString = numberFormatter.stringFromNumber( Double ( color.alphaComponent ) ) {
            returnString += " alpha:\(modifiedString)]"
        } else {
            print ( "Error converting alpha component \(color.alphaComponent) of color to a string" )
            return nil
        }
        
        return returnString
}
    
    
    private func colorStringForType ( colorType : CSRColorType ) -> String {
        
        switch colorType {
        case .NSColor:
            return "NS"
            
        case .UIColor:
            return "UI"
            
        default:
            return "Unknown Color Type"
        }
    }
}
