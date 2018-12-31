/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import AppKit

open class MessagesCollectionView: NSCollectionView {
  
  // MARK: - Properties
  
  open weak var messagesDataSource: MessagesDataSource?
  
  open weak var messagesDisplayDelegate: MessagesDisplayDelegate?
  
  open weak var messagesLayoutDelegate: MessagesLayoutDelegate?
  
  open weak var messageCellDelegate: MessageCellDelegate?
  
  open var showsDateHeaderAfterTimeInterval: TimeInterval = 3600
  
  open override var frame: NSRect {
    didSet {
      collectionViewLayout?.invalidateLayout()
    }
  }

  
  // MARK: - Initializers
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    wantsLayer = true
    layer?.backgroundColor = .white
    
    
    collectionViewLayout = MessagesCollectionViewFlowLayout()
    
    autoresizingMask = [.width, .maxXMargin, .minYMargin, .height, .maxXMargin]
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public convenience init() {
    self.init(frame: .zero)
  }
  
  // MARK: - Methods

  
//  private var indexPathForLastItem: IndexPath? {
//    let lastSection = numberOfSections - 1
//    guard lastSection >= 0, numberOfItems(inSection: lastSection) > 0 else { return nil }
//    return IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
//  }
  
  public func insertItemAfterLast() {

//    let sections = numberOfSections
    
//    let afterLastIndex = IndexPath(item: 0, section: sections)
//    let indexPaths: Set<IndexPath> = [afterLastIndex]
//    let sectionIndexSet = IndexSet(arrayLiteral: sections)
    insertSections([numberOfSections])
//    insertItems(at: indexPaths)
    
//    reloadData()
    
  }
  
  // TODO: - Manage NScrollView
  
  public func scrollToBottom(animated: Bool) {
    
    let sections = self.numberOfSections
    if sections > 0 {
      
      let rows = self.numberOfItems(inSection: sections - 1)
      let last = IndexPath(item: rows - 1, section: sections - 1)
      
      let indexes: Set<IndexPath> = [last]
      
      DispatchQueue.main.async {
        
        if animated {
          self.animator().scrollToItems(at: indexes, scrollPosition: NSCollectionView.ScrollPosition.bottom)
        } else {
          self.scrollToItems(at: indexes, scrollPosition: NSCollectionView.ScrollPosition.bottom)
        }
      }
    }
  }
  //
  //    public func reloadDataAndKeepOffset() {
  //        // stop scrolling
  //        setContentOffset(contentOffset, animated: false)
  //
  //        // calculate the offset and reloadData
  //        let beforeContentSize = contentSize
  //        reloadData()
  //        layoutIfNeeded()
  //        let afterContentSize = contentSize
  //
  //        // reset the contentOffset after data is updated
  //        let newOffset = CGPoint(
  //            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
  //            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
  //        setContentOffset(newOffset, animated: false)
  //    }
  
}
