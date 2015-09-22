//
//  BorderedColorWell.swift
//  
//
//  Created by Reid Gravelle on 2015-04-19.
//
//

import AppKit

class BorderedColorWell: NSColorWell {
    
    var borderColor : NSColor!
    
    
    override func drawRect(dirtyRect: NSRect) {
        
        NSGraphicsContext.saveGraphicsState()
        
        let path = NSBezierPath ( roundedRect: NSMakeRect( 0, -5, self.bounds.size.width, self.bounds.size.height + 5), xRadius: 5.0, yRadius: 5.0 )
        
        path.addClip()
        drawWellInside( self.bounds )
        
        NSGraphicsContext.restoreGraphicsState()
        
        
        if ( borderColor != nil ) {
            let borderPath = NSBezierPath ( roundedRect: NSInsetRect( NSMakeRect( 0, -5, self.bounds.size.width, self.bounds.size.height + 5), 0.5, 0.5 ) , xRadius: 5.0, yRadius: 5.0 )
            borderColor.setStroke()
            borderPath.stroke()
        }
    }
}
