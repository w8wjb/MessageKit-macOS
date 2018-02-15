//
//  GrowingTextView.swift
//  ChatExample
//
//  Created by Weston Bustraan on 12/02/2018.
//  Copyright © 2018 MessageKit-macOS. All rights reserved.
//

import Cocoa

class GrowingTextView: NSTextView {


    override var intrinsicContentSize: NSSize {
        guard let textContainer = self.textContainer else {
            return NSSize.zero
        }
        
        guard let layoutManager = self.layoutManager else {
            return NSSize.zero
        }
        
        layoutManager.ensureLayout(for: textContainer)
        
        return layoutManager.usedRect(for: textContainer).insetBy(dx: -textContainerInset.width,
                                                                  dy: -textContainerInset.height)
            .size
    }
    
    override func didChangeText() {
        super.didChangeText()
        invalidateIntrinsicContentSize()
    }
    
}
