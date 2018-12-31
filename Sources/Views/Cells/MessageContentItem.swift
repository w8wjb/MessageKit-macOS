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

/// A subclass of `MessageCollectionViewItem` used to display text, media, and location messages.
open class MessageContentItem: MessageCollectionViewItem {
  
  /// The image view displaying the avatar.
  open var avatarView = AvatarView()
  
  /// The container used for styling and holding the message's content view.
  open var messageContainerView: MessageContainerView = {
    let containerView = MessageContainerView()
//    containerView.layer?.clipsToBounds = true
    containerView.wantsLayer = true
    containerView.layer?.masksToBounds = true
    return containerView
  }()
  
  /// The top label of the cell.
  open var cellTopLabel: InsetLabel = {
    let label = InsetLabel()
    label.alignmentMode = .center
    return label
  }()
  
  /// The top label of the messageBubble.
  open var messageTopLabel: InsetLabel = {
    let label = InsetLabel()
    return label
  }()
  
  /// The bottom label of the messageBubble.
  open var messageBottomLabel: InsetLabel = {
    let label = InsetLabel()
    return label
  }()
  
  /// The `MessageCellDelegate` for the cell.
  open weak var delegate: MessageCellDelegate?
  
  open override func loadView() {
    view = NSView()
    view.autoresizingMask = [.width, .height]
    view.wantsLayer = true
    setupSubviews()

  }

  open func setupSubviews() {
    
    view.addSubview(messageContainerView)
    view.addSubview(avatarView)
    
    // Disable animation for position changes
    cellTopLabel.actions = ["position": NSNull()]
    cellTopLabel.contentsScale = NSScreen.main?.backingScaleFactor ?? 1
    view.layer?.addSublayer(cellTopLabel)

    messageTopLabel.actions = ["position": NSNull()]
    messageTopLabel.contentsScale = NSScreen.main?.backingScaleFactor ?? 1
    view.layer?.addSublayer(messageTopLabel)
    
    messageBottomLabel.actions = ["position": NSNull()]
    messageBottomLabel.contentsScale = NSScreen.main?.backingScaleFactor ?? 1
    view.layer?.addSublayer(messageBottomLabel)

  }
  
  open override func prepareForReuse() {
    super.prepareForReuse()
    cellTopLabel.string = nil
    messageTopLabel.string = nil
    messageBottomLabel.string = nil
  }
  
  // MARK: - Configuration
  
  open override func apply(_ layoutAttributes: NSCollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
    // Call this before other laying out other subviews
    layoutMessageContainerView(with: attributes)
    layoutBottomLabel(with: attributes)
    layoutCellTopLabel(with: attributes)
    layoutMessageTopLabel(with: attributes)
    layoutAvatarView(with: attributes)
  }
  
  /// Used to configure the cell.
  ///
  /// - Parameters:
  ///   - message: The `MessageType` this cell displays.
  ///   - indexPath: The `IndexPath` for this cell.
  ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell is contained.
  open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
    guard let dataSource = messagesCollectionView.messagesDataSource else {
      fatalError(MessageKitError.nilMessagesDataSource)
    }
    guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
      fatalError(MessageKitError.nilMessagesDisplayDelegate)
    }
    
    delegate = messagesCollectionView.messageCellDelegate
    
    let messageColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
    let messageStyle = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)
    
    displayDelegate.configureAvatarView(avatarView, for: message, at: indexPath, in: messagesCollectionView)
    
    messageContainerView.layer?.backgroundColor = messageColor.cgColor
    messageContainerView.style = messageStyle
    
    let topCellLabelText = dataSource.cellTopLabelAttributedText(for: message, at: indexPath)
    let topMessageLabelText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath)
    let bottomText = dataSource.messageBottomLabelAttributedText(for: message, at: indexPath)
    
    cellTopLabel.string = topCellLabelText
    messageTopLabel.string = topMessageLabelText
    messageBottomLabel.string = bottomText
  }
  
//  /// Handle tap gesture on contentView and its subviews.
//  open func handleTapGesture(_ gesture: UIGestureRecognizer) {
//    let touchLocation = gesture.location(in: self)
//
//    switch true {
//    case messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
//      delegate?.didTapMessage(in: self)
//    case avatarView.frame.contains(touchLocation):
//      delegate?.didTapAvatar(in: self)
//    case cellTopLabel.frame.contains(touchLocation):
//      delegate?.didTapCellTopLabel(in: self)
//    case messageTopLabel.frame.contains(touchLocation):
//      delegate?.didTapMessageTopLabel(in: self)
//    case messageBottomLabel.frame.contains(touchLocation):
//      delegate?.didTapMessageBottomLabel(in: self)
//    case accessoryView.frame.contains(touchLocation):
//      delegate?.didTapAccessoryView(in: self)
//    default:
//      break
//    }
//  }
  
  // MARK: - Origin Calculations
  
  /// Positions the cell's `AvatarView`.
  /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
  open func layoutAvatarView(with attributes: MessagesCollectionViewLayoutAttributes) {
    var origin: CGPoint = .zero
    
    switch attributes.avatarPosition.horizontal {
    case .cellLeading:
      break
    case .cellTrailing:
      origin.x = attributes.frame.width - attributes.avatarSize.width
    case .natural:
      fatalError(MessageKitError.avatarPositionUnresolved)
    }
    
    switch attributes.avatarPosition.vertical {
    case .messageLabelTop:
      origin.y = messageTopLabel.frame.minY
    case .messageTop: // Needs messageContainerView frame to be set
      origin.y = messageContainerView.frame.minY
    case .messageBottom: // Needs messageContainerView frame to be set
      origin.y = messageContainerView.frame.maxY - attributes.avatarSize.height
    case .messageCenter: // Needs messageContainerView frame to be set
      origin.y = messageContainerView.frame.midY - (attributes.avatarSize.height/2)
    case .cellBottom:
      origin.y = attributes.frame.height - attributes.avatarSize.height
    default:
      break
    }
    
    avatarView.frame = CGRect(origin: origin, size: attributes.avatarSize)
  }
  
  /// Positions the cell's `MessageContainerView`.
  /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
  open func layoutMessageContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
    var origin: CGPoint = .zero
    
    switch attributes.avatarPosition.vertical {
    case .messageBottom:
      origin.y = attributes.size.height - attributes.messageContainerPadding.bottom - attributes.messageBottomLabelSize.height - attributes.messageContainerSize.height - attributes.messageContainerPadding.top
    case .messageCenter:
      if attributes.avatarSize.height > attributes.messageContainerSize.height {
        let messageHeight = attributes.messageContainerSize.height + attributes.messageContainerPadding.vertical
        origin.y = (attributes.size.height / 2) - (messageHeight / 2)
      } else {
        fallthrough
      }
    default:
      if attributes.accessoryViewSize.height > attributes.messageContainerSize.height {
        let messageHeight = attributes.messageContainerSize.height + attributes.messageContainerPadding.vertical
        origin.y = (attributes.size.height / 2) - (messageHeight / 2)
      } else {
        origin.y = attributes.cellTopLabelSize.height + attributes.messageTopLabelSize.height + attributes.messageContainerPadding.top
      }
    }
    
    switch attributes.avatarPosition.horizontal {
    case .cellLeading:
      origin.x = attributes.avatarSize.width + attributes.messageContainerPadding.left
    case .cellTrailing:
      origin.x = attributes.frame.width - attributes.avatarSize.width - attributes.messageContainerSize.width - attributes.messageContainerPadding.right
    case .natural:
      fatalError(MessageKitError.avatarPositionUnresolved)
    }
    
    messageContainerView.frame = CGRect(origin: origin, size: attributes.messageContainerSize)
  }
  
  /// Positions the cell's top label.
  /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
  open func layoutCellTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
    cellTopLabel.frame = CGRect(origin: .zero, size: attributes.cellTopLabelSize)
  }
  
  /// Positions the message bubble's top label.
  /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
  open func layoutMessageTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
    messageTopLabel.alignmentMode = attributes.messageTopLabelAlignment.textAlignment.layerAlignment
    
    // TODO: CALayer insets
//    messageTopLabel.textInsets = attributes.messageTopLabelAlignment.textInsets
    
    let y = messageContainerView.frame.minY - attributes.messageContainerPadding.top - attributes.messageTopLabelSize.height
    let origin = CGPoint(x: 0, y: y)
    
    messageTopLabel.frame = CGRect(origin: origin, size: attributes.messageTopLabelSize)
  }
  
  /// Positions the cell's bottom label.
  /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
  open func layoutBottomLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
    messageBottomLabel.alignmentMode = attributes.messageBottomLabelAlignment.textAlignment.layerAlignment

    // TODO: CALayer insets
//    messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets
    
    let y = messageContainerView.frame.maxY + attributes.messageContainerPadding.bottom
    let origin = CGPoint(x: 0, y: y)
    
    messageBottomLabel.frame = CGRect(origin: origin, size: attributes.messageBottomLabelSize)
  }
  
}
