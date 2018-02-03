//
//  NSFont+Extensions.swift
//  MessageKit
//
//  Created by Weston Bustraan on 02/02/2018.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import AppKit

extension NSFont {
    
    class func preferredFont(forTextStyle style: FontTextStyle) -> NSFont {
        let size: CGFloat
        switch style {
        default:
            size = NSFont.systemFontSize(for: .regular)
        }
        return NSFont.systemFont(ofSize: size)
    }
    
    func withSize(_ fontSize: CGFloat) -> NSFont {
        return NSFont(descriptor: self.fontDescriptor, size: fontSize)!
    }
}

enum FontTextStyle {
    
    /** The font used for body text. */
    case body
    
    /** The font used for callouts. */
    case callout
    
    /** The font used for standard captions. */
    case caption1
    
    /** The font used for alternate captions. */
    case caption2
    
    /** The font used in footnotes. */
    case footnote
    
    /** The font used for headings. */
    case headline
    
    /** The font used for subheadings. */
    case subheadline
    
    /** The font style for large titles. */
    case largeTitle
    
    /** The font used for first level hierarchical headings. */
    case title1
    
    /** The font used for second level hierarchical headings. */
    case title2
    
    /** The font used for third level hierarchical headings. */
    case title3
    
}

