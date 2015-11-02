//
//  IntegerSeeker.swift
//  ColorSenseRainbow
//
//  Created by Stroganov Ilya on 02/11/15.
//  Copyright © 2015 Ilya Stroganov. All rights reserved.
//

import Cocoa

class IntegerSeeker: Seeker {
	
	override init () {
		super.init()
		
		var error : NSError?
		
		
		var regex: NSRegularExpression?
		
		do {
			regex = try NSRegularExpression(
				pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWithInteger:\\s*0x([0-9a-fA-F]{6})\\s*\\]",
				options: []
			)
			
		} catch let error1 as NSError {
			error = error1
			regex = nil
		}
		
		if regex == nil {
			print ( "Error creating Swift Integer float with alpha regex = \(error?.localizedDescription)" )
		} else {
			regexes.append( regex! )
		}

		do {
			regex = try NSRegularExpression(
				pattern: "(?:NS|UI)Color.colorWithInteger\\s*\\(\\s*0x([0-9a-fA-F]{6})\\s*\\)",
				options: []
			)
			
		} catch let error1 as NSError {
			error = error1
			regex = nil
		}
		
		if regex == nil {
			print ( "Error creating Swift Integer float with alpha regex = \(error?.localizedDescription)" )
		} else {
			regexes.append( regex! )
		}

		
		
		do {
			regex = try NSRegularExpression(
				pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWithInteger:\\s*0x([0-9a-fA-F]{6})\\s*alpha:\\s*([\\.0-9]+)f?\\s*\\]",
				options: []
			)
			
		} catch let error1 as NSError {
			error = error1
			regex = nil
		}
		
		if regex == nil {
			print ( "Error creating Swift Integer float with alpha regex = \(error?.localizedDescription)" )
		} else {
			regexes.append( regex! )
		}

		
		do {
			regex = try NSRegularExpression(
				pattern: "(?:NS|UI)Color.colorWithInteger\\s*\\(\\s*0x([0-9a-fA-F]{6})\\s*,\\s*alpha\\s*:\\s*([\\.0-9]+)f?\\)",
				options: []
			)
			
		} catch let error1 as NSError {
			error = error1
			regex = nil
		}
		
		if regex == nil {
			print ( "Error creating Swift Integer float with alpha regex = \(error?.localizedDescription)" )
		} else {
			regexes.append( regex! )
		}

		
		
	}
	
	
	override func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
		
		if ( match.numberOfRanges == 2 || match.numberOfRanges == 3 ) {
			
			let matchString = stringFromRange( match.range, line: line )
			let integerString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
			
			var alphaString = "1.0"
			
			if( match.numberOfRanges == 3 ){
				alphaString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
			}
			
			let capturedStrings = [ matchString, integerString, alphaString ]
			
			let alphaValue = CGFloat ( (alphaString as NSString).doubleValue )
			
			let integerColor = NSColor(hexString: integerString, alpha: alphaValue)
			if let color = integerColor.colorUsingColorSpace( NSColorSpace.genericRGBColorSpace() ) {
				
				var searchResult = SearchResult ( color: color, textCheckingResult: match, capturedStrings: capturedStrings )
				searchResult.creationType = .DefaultWhite
				
				return searchResult
			}
		}
		
		return nil
	}
	
	
}
