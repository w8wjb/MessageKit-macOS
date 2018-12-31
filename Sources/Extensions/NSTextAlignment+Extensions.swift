//
//  NSTextAlignment+Extensions.swift
//  MessageKit-macOS
//
//  Created by Weston Bustraan on 12/31/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Foundation

extension NSTextAlignment {
  
  var layerAlignment: CATextLayerAlignmentMode {
    get {
      switch self {
      case .center:
        return CATextLayerAlignmentMode.center
      case .justified:
        return CATextLayerAlignmentMode.justified
      case .left:
        return CATextLayerAlignmentMode.left
      case .natural:
        return CATextLayerAlignmentMode.natural
      case .right:
        return CATextLayerAlignmentMode.right
      }
    }
  }
  
}
