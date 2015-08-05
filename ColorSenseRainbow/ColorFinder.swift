//
//  ColorFinder.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-19.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class ColorFinder : Printable {
    
    var seekers : [ Seeker ] = [
        RGBCalculatedSeeker(),
        RGBFloatSeeker(),
        PredefinedColorSeeker(),
        WhiteSeeker(),
        RainbowIntSeeker(),
        RainbowHexadecimalStringSeeker(),
        RainbowHexadecimalIntSeeker(),
        HSBFloatSeeker()
    ]
    
    var description : String {
        return "ColorFinder with \(seekers.count) Seekers"
    }
    
    
    func searchForColor( line : String, selectedRange : NSRange ) -> SearchResult? {
        
        // Do a quick check for "Color in the line.  Everything we search for is of the for "NSColor ..." or
        // "UIColor ..." so if Color isn't found then there's no need to run all of the other searches.
        
        if line.rangeOfString( "Color" ) != nil  {
            for seeker in ( seekers ) {
                if let searchResult = seeker.searchForColor( line, selectedRange: selectedRange ) {
                    return searchResult
                }
            }
        }
        
        
        return nil
    }
}
