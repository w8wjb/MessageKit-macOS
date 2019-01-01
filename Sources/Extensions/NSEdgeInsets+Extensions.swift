//
//  NSEdgeInsets+Extensions.swift
//  MessageKit-macOS
//
//  Created by Weston Bustraan on 1/1/19.
//  Copyright © 2019 MessageKit. All rights reserved.
//

import Foundation

extension NSEdgeInsets {
  
  internal var vertical: CGFloat {
    return top + bottom
  }
  
  internal var horizontal: CGFloat {
    return left + right
  }
  
  init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
    self.init(top: top, left: left, bottom: bottom, right: right)
  }
}

extension NSEdgeInsets: Equatable {
  public static func ==(lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
    return NSEdgeInsetsEqual(lhs, rhs)
  }
}
