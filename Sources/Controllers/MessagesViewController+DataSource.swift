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

extension MessagesViewController: NSCollectionViewDataSource {
  
  open func numberOfSections(in collectionView: NSCollectionView) -> Int {
    guard let collectionView = collectionView as? MessagesCollectionView else {
      fatalError(MessageKitError.notMessagesCollectionView)
    }
    return collectionView.messagesDataSource?.numberOfSections(in: collectionView) ?? 0
  }
  
  open func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let collectionView = collectionView as? MessagesCollectionView else {
      fatalError(MessageKitError.notMessagesCollectionView)
    }
    return collectionView.messagesDataSource?.numberOfItems(inSection: section, in: collectionView) ?? 0
  }
  
  public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    
    guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
      fatalError(MessageKitError.notMessagesCollectionView)
    }
    
    guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
      fatalError(MessageKitError.nilMessagesDataSource)
    }
    
    let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
    
    switch message.kind {
    case .text, .attributedText, .emoji:
      let item = messagesCollectionView.makeItem(TextMessageItem.self, for: indexPath)
      item.configure(with: message, at: indexPath, and: messagesCollectionView)
      return item
    case .photo, .video:
      let item = messagesCollectionView.makeItem(MediaMessageItem.self, for: indexPath)
      item.configure(with: message, at: indexPath, and: messagesCollectionView)
      return item
    case .location:
      let item = messagesCollectionView.makeItem(LocationMessageItem.self, for: indexPath)
      item.configure(with: message, at: indexPath, and: messagesCollectionView)
      return item
    case .custom:
      return messagesDataSource.customItem(for: message, at: indexPath, in: messagesCollectionView)
    }
  }
  
  
  public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> CollectionViewReusable {
    
    guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
      fatalError(MessageKitError.notMessagesCollectionView)
    }
    
    guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
      fatalError(MessageKitError.nilMessagesDisplayDelegate)
    }
    
    switch kind {
    case NSCollectionView.elementKindSectionHeader:
      return displayDelegate.messageHeaderView(for: indexPath, in: messagesCollectionView)
    case NSCollectionView.elementKindSectionFooter:
      return displayDelegate.messageFooterView(for: indexPath, in: messagesCollectionView)
    default:
      fatalError(MessageKitError.unrecognizedSectionKind)
    }
  }
}
