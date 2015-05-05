//
//  ColorBuilderFactory.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-25.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class ColorBuilderFactory {
    
    /**
    Returns the proper ColorBuilder object for the given SearchResult object.  It looks at the creation type enumerated value stored in the search result to determine which ColorBuilder to return.
    
    :param: search The SearchResult object used to determine the ColorBuilder to return.
    
    :returns: A ColorBuilder object.
    */
    
    func builderForCreationType ( search : SearchResult ) -> ColorBuilder? {

        switch search.creationType {

        case .RGBCalculated:
            return CalculatedRGBBuilder()
            
        case .PredefinedColor:
            return PredefinedColorBuilder()
            
        case .RainbowHexString:
            return RainbowHexBuilder()
            
        case .RainbowHexInt:
            return RainbowHexBuilder()
            
        case .RainbowInt:
            return RainbowIntBuilder()
            
        case .DefaultRGB:
            return DefaultRGBBuilder()
            
        case .Unknown:
            return nil
        }
    }

}
