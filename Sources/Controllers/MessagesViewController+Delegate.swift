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

extension MessagesViewController: NSCollectionViewDelegateFlowLayout {
  
  open func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
    return messagesFlowLayout.sizeForItem(at: indexPath)
  }
  
  open func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
    
    guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
      fatalError(MessageKitError.notMessagesCollectionView)
    }
    guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
      fatalError(MessageKitError.nilMessagesLayoutDelegate)
    }
    return layoutDelegate.headerViewSize(for: section, in: messagesCollectionView)
  }
  
  open func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
      fatalError(MessageKitError.notMessagesCollectionView)
    }
    guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
      fatalError(MessageKitError.nilMessagesLayoutDelegate)
    }
    return layoutDelegate.footerViewSize(for: section, in: messagesCollectionView)
  }
  
  open func collectionView(_ collectionView: NSCollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
    guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return false }
    let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
    
    switch message.kind {
    case .text, .attributedText, .emoji, .photo:
      selectedIndexPathForMenu = indexPath
      return true
    default:
      return false
    }
  }
  
  open func collectionView(_ collectionView: NSCollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    return (action == NSSelectorFromString("copy:"))
  }
  
  open func collectionView(_ collectionView: NSCollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
      fatalError(MessageKitError.nilMessagesDataSource)
    }
    let pasteBoard = NSPasteboard.general
    let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
    
    switch message.kind {
    case .text(let text), .emoji(let text):
      pasteBoard.setString(text, forType: .string)
    case .attributedText(let attributedText):
      pasteBoard.setString(attributedText.string, forType: .string)
    case .photo(let mediaItem):
      pasteBoard.writeObjects([mediaItem.image ?? mediaItem.placeholderImage])
    default:
      break
    }
  }
}
