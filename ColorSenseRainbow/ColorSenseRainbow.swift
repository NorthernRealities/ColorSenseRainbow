//
//  ColorSenseRainbow.swift
//
//  Created by Reid Gravelle on 2015-04-18.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

var token : dispatch_once_t = 0


class ColorSenseRainbow: NSObject {
    let defaultsString = "ColorSenseRainbowEnabled"
    
    var colorFinder = ColorFinder()
    let cbc = ColorBuilderFactory()
    
    var bundle: NSBundle
    
    var enabled = true  // The default value.
    
    var colorWells : [ NSTextView : BorderedColorWell ] = [:]
    var colorFrames : [ NSTextView : ColorFrameView ] = [:]
    var searchResults : [ NSTextView : SearchResult ] = [:]
    
    var actionMenuItem : NSMenuItem!
    
    static var sharedPlugin: ColorSenseRainbow?
    
    
    class func pluginDidLoad( bundle: NSBundle ) {
        if let  infoDict = NSBundle.mainBundle().infoDictionary,
                appNameObj = infoDict[ "CFBundleName" ] {
                    if appNameObj is String {
                        
                        let appName = appNameObj as! NSString
                        if appName == "Xcode" {
                            dispatch_once( &token ) {
                                self.sharedPlugin = ColorSenseRainbow(bundle: bundle)
                            }
                        }

                    }
        }
    }

    
    /**
    Sets up to receive a notification when the application has finished loading so that the rest of the plugin can be initialized.
    
    - parameter bundle: Resources for the program.
    
    - returns: N/A
    */
    
    init ( bundle: NSBundle ) {
        self.bundle = bundle

        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(ColorSenseRainbow.applicationFinishedLoading(_:)), name: NSApplicationDidFinishLaunchingNotification, object: nil )
    }
    

    /**
    The function called when the object has reached the end of it's life.  It removes itself from receiving any further notifications.
    */
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    /**
    This function is called once the application has finished loading and will call functions that load the enabled state from NSUserDefaults, create any necessary menu items, and activate or deactivate the color highlighting depending on the enabled state.  It also removes the object as a listener from getting more NSApplicationDidFinishLaunchingNotification notifications (not that it should).
    
    - parameter notification: The notification object.
    */
    
    func applicationFinishedLoading ( notification : NSNotification ) {
        
        NSNotificationCenter.defaultCenter().removeObserver( self, name: NSApplicationDidFinishLaunchingNotification, object: nil )
        
        loadEnabledState()
        createMenuItems()
        
        enabled ? activateColorHighlighting() : deactivateColorHighlighting()

    }
    
    
    /**
    If the Edit menu is present then this function adds a separator and a new item to toggle the color highlighting at the bottom of it.  If the color highlighting is currently enabled the menu item will have a checkmark next to it.
    */
    
    func createMenuItems() {
        
        let item = NSApp.mainMenu!.itemWithTitle("Edit")
        if item != nil {
            actionMenuItem = NSMenuItem(title:"Show Colors Under Carat", action:#selector(ColorSenseRainbow.toggleColorsUnderCarat), keyEquivalent:"")
            actionMenuItem.target = self
            
            if enabled == true {
                actionMenuItem.state = NSOnState
            }
            
            item!.submenu!.addItem(NSMenuItem.separatorItem())
            item!.submenu!.addItem(actionMenuItem)
        }
    }

    
    /**
    This function reads the enabled state from NSUserDefaults, if present, toggles the value, writes out the new value, and calls the appropriate function to activate or deactivate the color highlighting.
    */
    
    func toggleColorsUnderCarat() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let _: AnyObject = defaults.objectForKey( defaultsString ) {
            // It exists so grab the value from defaults.
            
            enabled = defaults.boolForKey( defaultsString )
        }
        
        enabled = !enabled
        defaults.setBool( enabled, forKey: defaultsString )
        
        enabled ? activateColorHighlighting() : deactivateColorHighlighting()
    }
    
    
    /**
    Examines the current line of text for the NSTextView contained in the notification for a definition of a color object and if it finds one then it displays a ColorWell and ColorFrame.
    
    - parameter notification: The NSNotification generated by the NSTextView when the selection was changed (ie. the caret was moved).
    */
    
    func selectionDidChange ( notification: NSNotification ) {
                
        if ( enabled == false ) {
            return
        }
        
        
        if ( notification.object is NSTextView ) {
            let textView = notification.object as! NSTextView
            
            // Returns an NSRange of where the caret is but if there are characters that take up 
            // multiple unicode characters (emoticons, etc) then the range value we get back will
            // be wrong.
            
            let selectedRanges = textView.selectedRanges
            
            if ( selectedRanges.count > 0 ) {
                if let firstRange = selectedRanges.first {
                    let selectedRange = firstRange.rangeValue

                    let text = textView.textStorage?.string
                    let nsText = NSString ( string: text! )
                    
                    // Grab the line of text that caret is on.
                    // Could be wrong because because selectedRanges works with NSRanges instead of Ranges.
                    
                    let lineRange = nsText.lineRangeForRange( selectedRange )
                    let selectedRangeInLine = NSMakeRange( selectedRange.location - lineRange.location , selectedRange.length )
                    let line = nsText.substringWithRange( lineRange )
                    
                    
                    if var searchResult = colorFinder.searchForColor( line, selectedRange: selectedRangeInLine ) {
                        if let backgroundColor = textView.backgroundColor.colorUsingColorSpace( NSColorSpace.genericRGBColorSpace() ) {
                            
                            let backgroundLuminance = ( backgroundColor.redComponent + backgroundColor.greenComponent + backgroundColor.blueComponent ) / 3.0
                            
                            let borderColor = ( backgroundLuminance > 0.5 ) ? NSColor ( calibratedWhite: 0.2, alpha: 1.0 ) : NSColor.whiteColor()

                            var colorWell : BorderedColorWell!
                            
                            if let cw = colorWells[ textView ] {
                                colorWell = cw
                                colorWell.deactivate()
                            } else {
                                colorWell = BorderedColorWell ()
                            }
                            
                            colorWell.color = searchResult.color
                            colorWell.borderColor = borderColor
                            
                            let selectedColorRange = NSMakeRange( searchResult.tcr.range.location + lineRange.location, searchResult.tcr.range.length )
                            let selectionRectOnScreen = textView.firstRectForCharacterRange( selectedColorRange, actualRange: nil )
                            if let selectionRectInWindow = textView.window?.convertRectFromScreen( selectionRectOnScreen ) {
                                let selectionRectInView = textView.convertRect( selectionRectInWindow, fromView: nil )
                                let colorWellRect = NSMakeRect( NSMaxX ( selectionRectInView ) - 49, NSMinY( selectionRectInView ) - selectionRectInView.size.height - 2, 50, selectionRectInView.size.height + 2 )

                                colorWell.frame = NSIntegralRect( colorWellRect )
                                colorWell.target = self
                                colorWell.action = NSSelectorFromString( "colorChanged:" )

                                addColorWell( colorWell, toTextView: textView )


                                let colorFrame = ColorFrameView()
                                colorFrame.frame = NSInsetRect( NSIntegralRect( selectionRectInView ), -1, -1 )
                                colorFrame.color = borderColor

                                addColorFrame( colorFrame, toTextView: textView )
                            }

                            searchResult.rangeInTextView = selectedColorRange
                            searchResults[ textView ] = searchResult
                        }
                    } else {
                        dismissColorWell( textView )
                    }
                }
            }
        }
    }
    
    
    /**
    Dismisses the ColorWell and ColorFrame from a NSWindow that is about to close and removes them, plus the NSTextView associated with the NSWindow, from the internal data storage.
    
    - parameter notification: A NSNotification that contains the NSWindow which is closing.
    */
    
    func windowWillClose ( notification: NSNotification ) {
        
        if ( enabled == false ) {
            return
        }
        
        let windowClosing = notification.object as? NSWindow
        
        for textView in colorWells.keys {
            if ( ( textView.window == windowClosing ) || ( textView.window == nil ) ) {
                dismissColorWell( textView )
                break
            }
        }
    }
    
    
    /**
    When the user changes the color this function gets invoked.  It determines the proper NSTextView to make the change in and calls a method to perform that functionality.
    
    - parameter sender: The object, which should be the color well, that is having the color changed.
    */
    
    func colorChanged ( sender : AnyObject ) {
        
        if let colorWell = sender as? BorderedColorWell {
            for textView in colorWells.keys {
                if colorWell == colorWells[ textView ] {
                    handleColorChangeForTextView ( textView )
                    
                    // Call activate or else next color change won't be reflected.
                    colorWell.activate( false )
                }
            }
        }
    }
    
    
    /**
    Gets the enabled state from standard user defaults or sets it to the default value of true if it isn't present.
    */
    
    private func loadEnabledState() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let _: AnyObject = defaults.objectForKey( defaultsString ) {
            // It exists so grab the value from defaults.
            
            enabled = defaults.boolForKey( defaultsString )
        } else {
            // Next time it'll be set to our default unless changed.
            
            defaults.setBool( enabled, forKey: defaultsString )
        }
    }
    
    
    /**
    Enables the color highlighting by starting to listen for notifications and puts the checkmark beside the menu item.  The NSTextViewDidChangeSelectionNotification is used to capture when the caret is moved.  The NSWindowWillCloseNotification lets us know that a window will close so that the items can be removed from the internal data storage.  If this wasn't done then we'd hang onto the NSTextViews preventing the memory from being freed.
    */
    
    private func activateColorHighlighting() {
        
        actionMenuItem.state = NSOnState
        
        NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(ColorSenseRainbow.selectionDidChange(_:)), name: NSTextViewDidChangeSelectionNotification, object: nil )
        NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(NSWindowDelegate.windowWillClose(_:)), name: NSWindowWillCloseNotification, object: nil )
    }
    
    
    /**
    Turns off the color highlighting by dismissing all existing ColorWells and turning off the receiving of any notifications.  It also turns off the checkmark beside the menu item in the Edit menu.
    */
    
    private func deactivateColorHighlighting() {
        
        actionMenuItem.state = NSOffState
        
        NSNotificationCenter.defaultCenter().removeObserver( self, name: NSTextViewDidChangeSelectionNotification, object: nil )
        NSNotificationCenter.defaultCenter().removeObserver( self, name: NSWindowWillCloseNotification, object: nil )
        
        dismissAllColorWells()
    }
    
    
    /**
    Adds the given ColorWell to the NSTextView and to the data structure of the object.  If an existing ColorWell displayed it is removed from the NSTextView first.
    
    - parameter colorWell:  The ColorWell to display.
    - parameter toTextView: The NSTextView that displays the ColorWell.
    */
    
    private func addColorWell ( colorWell : BorderedColorWell, toTextView : NSTextView ) {
        
        if let oldColorWell = colorWells[ toTextView ] {
            oldColorWell.removeFromSuperview()
        }
        
        colorWells[ toTextView ] = colorWell
        toTextView.addSubview( colorWell )
    }
    
    
    /**
    Adds the specified ColorFrame to the NSTextView and also to the data structure within the object.  If there is an existing ColorFrame on the NSTextView then it is removed before.
    
    - parameter colorFrame: The ColorFrame to add.
    - parameter toTextView: The NSTextView that displays the ColorFrame.
    */
    
    private func addColorFrame ( colorFrame : ColorFrameView, toTextView : NSTextView ) {
        
        if let oldColorFrame = colorFrames[ toTextView ] {
            oldColorFrame.removeFromSuperview()
        }
        
        colorFrames[ toTextView ] = colorFrame
        toTextView.addSubview( colorFrame )
    }
    
    
    /**
    Removes the color well and the color frame from the specified NSTextView and from the associated data structures of the object.
    
    - parameter fromTextView: The NSTextView from which to remove the color well and color frame.
    */
    
    private func dismissColorWell( fromTextView : NSTextView ) {
        
        if let colorWell = colorWells[ fromTextView ] {
            colorWell.removeFromSuperview()
            colorWells.removeValueForKey( fromTextView )
        }
        
        
        if let colorFrame = colorFrames[ fromTextView ] {
            colorFrame.removeFromSuperview()
            colorFrames.removeValueForKey( fromTextView )
        }
        
        
        if let _ = searchResults[ fromTextView ] {
            searchResults.removeValueForKey( fromTextView )
        }
    }
    
    
    /**
    Causes all known color wells and color frames to be removed from the views and then from the data structures within this object.
    */
    
    private func dismissAllColorWells () {
        
        for textView in colorWells.keys {
            dismissColorWell( textView )
        }
    }
    
    
    /**
    Performs the swapping of the code describing when the user has changed the color providing that the appropriate ColorBuilder object is able to create the replacement. If anything goes wrong, such as not being able to get the proper ColorBuilder or finding the SearchResults for the NSTextView that is passed in, then nothing is done.
    
    - parameter textView: An NSTextView object which contains the code to replace.
    */
    
    private func handleColorChangeForTextView ( textView : NSTextView ) {
        
        if let  sr = searchResults[ textView ],
                builder = cbc.builderForCreationType( sr ),
                colorWell = colorWells[ textView ],
                color = colorWell.color.colorUsingColorSpace( NSColorSpace.genericRGBColorSpace() ),
                newColorString = builder.stringForColor( color, forSearchResult: sr ) {
                
            textView.undoManager?.beginUndoGrouping()
            textView.insertText( newColorString, replacementRange: sr.rangeInTextView )
            textView.undoManager?.endUndoGrouping()
        }
    }
    
    
    
}

