//
//  ColorFrameView.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-19.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class ColorFrameView: NSView {

    var color : NSColor!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        
        self.color.setStroke()
        NSBezierPath.strokeRect( NSInsetRect( self.bounds, 0.5, 0.5 ) )
    }
    
}
