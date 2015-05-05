//
//  NSColor+HexString.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-27.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

extension NSColor {
    

    /**
    Returns a string representing the color as a hexadecimal value of the format AABBCC where AA represents the red component, BB is the green component, and CC is the blue component in the RGB system.  Each character can be from 0-9 or A-F.
    
    :returns: A String with the hexadecimal representation or "FFFFFF" if an error happened.
    */
    
    func asHexString () -> String {
        
        var color = self
        
        
        // Need to convert the color to RGB if not already.
        
        if ( self.colorSpace != NSCalibratedRGBColorSpace ) && ( self.colorSpace != NSDeviceRGBColorSpace ) {
            if let convertedColor = self.colorUsingColorSpace( NSColorSpace.deviceRGBColorSpace() ) {
                color = convertedColor
            }
            else {
                return "FFFFFF"
            }
        }
        
        
        let componentArray = [ color.redComponent, color.greenComponent, color.blueComponent ]
        
        let stringArray = componentArray.map{ (value) -> String in
            if ( value == 0 ) {
                return "00"
            }
            
            var hexString = String ( Int ( round ( value * 255 ) ), radix: 16, uppercase: true )
            
            if ( count( hexString ) == 1 ) {
                hexString = "0\(hexString)"
            }
            
            return hexString
        }
        
        return "".join( stringArray )
    }
}