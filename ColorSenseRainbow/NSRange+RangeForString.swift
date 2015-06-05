//
//  NSRange+RangeForString.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-27.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

extension NSRange {
    
    func calculateRangeInString ( inString : String ) -> Range<String.Index> {
        
        return Range<String.Index>( start: advance( inString.startIndex, self.location ), end: advance( inString.startIndex, self.location + self.length ) )
        
    }
}