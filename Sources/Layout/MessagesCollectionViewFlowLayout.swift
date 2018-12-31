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
import AVFoundation

/// The layout object used by `MessagesCollectionView` to determine the size of all
/// framework provided `MessageCollectionViewItem` subclasses.
open class MessagesCollectionViewFlowLayout: NSCollectionViewFlowLayout {
  
  open override class var layoutAttributesClass: AnyClass {
    return MessagesCollectionViewLayoutAttributes.self
  }
  
  /// The `MessagesCollectionView` that owns this layout object.
  public var messagesCollectionView: MessagesCollectionView {
    guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
      fatalError(MessageKitError.layoutUsedOnForeignType)
    }
    return messagesCollectionView
  }
  
  /// The `MessagesDataSource` for the layout's collection view.
  public var messagesDataSource: MessagesDataSource {
    guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
      fatalError(MessageKitError.nilMessagesDataSource)
    }
    return messagesDataSource
  }
  
  /// The `MessagesLayoutDelegate` for the layout's collection view.
  public var messagesLayoutDelegate: MessagesLayoutDelegate {
    guard let messagesLayoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
      fatalError(MessageKitError.nilMessagesLayoutDelegate)
    }
    return messagesLayoutDelegate
  }
  
  public var itemWidth: CGFloat {
    guard let collectionView = collectionView else { return 0 }
    return collectionView.frame.width - sectionInset.left - sectionInset.right
  }
  
  // MARK: - Initializers
  
  public override init() {
    super.init()
    
    setupView()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setupView()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Methods
  
  private func setupView() {
    sectionInset = NSEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
  }

  // MARK: - Attributes
  
  open override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {
    guard let attributesArray = super.layoutAttributesForElements(in: rect) as? [MessagesCollectionViewLayoutAttributes] else {
      return []
    }
    for attributes in attributesArray where attributes.representedElementCategory == .item {
      if let indexPath = attributes.indexPath {
        let cellSizeCalculator = cellSizeCalculatorForItem(at: indexPath)
        cellSizeCalculator.configure(attributes: attributes)
      }
    }
    return attributesArray
  }
  
  open override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
    guard let attributes = super.layoutAttributesForItem(at: indexPath) as? MessagesCollectionViewLayoutAttributes else {
      return nil
    }
    if attributes.representedElementCategory == .item {
      guard let indexPath = attributes.indexPath else { return attributes }
      let cellSizeCalculator = cellSizeCalculatorForItem(at: indexPath)
      cellSizeCalculator.configure(attributes: attributes)
    }
    return attributes
  }
  
  // MARK: - Layout Invalidation
  
  open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return collectionView?.bounds.width != newBounds.width
  }
  
  open override func invalidationContext(forBoundsChange newBounds: CGRect) -> NSCollectionViewLayoutInvalidationContext {
    let context = super.invalidationContext(forBoundsChange: newBounds)
    guard let flowLayoutContext = context as? NSCollectionViewFlowLayoutInvalidationContext else { return context }
    flowLayoutContext.invalidateFlowLayoutDelegateMetrics = shouldInvalidateLayout(forBoundsChange: newBounds)
    return flowLayoutContext
  }
  
  // MARK: - Cell Sizing
  
  lazy open var textMessageSizeCalculator = TextMessageSizeCalculator(layout: self)
  lazy open var attributedTextMessageSizeCalculator = TextMessageSizeCalculator(layout: self)
  lazy open var emojiMessageSizeCalculator: TextMessageSizeCalculator = {
    let sizeCalculator = TextMessageSizeCalculator(layout: self)
    sizeCalculator.messageLabelFont = NSFont.systemFont(ofSize: sizeCalculator.messageLabelFont.pointSize * 2)
    return sizeCalculator
  }()
  lazy open var photoMessageSizeCalculator = MediaMessageSizeCalculator(layout: self)
  lazy open var videoMessageSizeCalculator = MediaMessageSizeCalculator(layout: self)
  lazy open var locationMessageSizeCalculator = LocationMessageSizeCalculator(layout: self)
  
  /// - Note:
  ///   If you override this method, remember to call MessageLayoutDelegate's customCellSizeCalculator(for:at:in:) method for MessageKind.custom messages, if necessary
  open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
    let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
    switch message.kind {
    case .text:
      return textMessageSizeCalculator
    case .attributedText:
      return attributedTextMessageSizeCalculator
    case .emoji:
      return emojiMessageSizeCalculator
    case .photo:
      return photoMessageSizeCalculator
    case .video:
      return videoMessageSizeCalculator
    case .location:
      return locationMessageSizeCalculator
    case .custom:
      return messagesLayoutDelegate.customCellSizeCalculator(for: message, at: indexPath, in: messagesCollectionView)
    }
  }
  
  open func sizeForItem(at indexPath: IndexPath) -> CGSize {
    let calculator = cellSizeCalculatorForItem(at: indexPath)
    return calculator.sizeForItem(at: indexPath)
  }
  
  /// Set `incomingAvatarSize` of all `MessageSizeCalculator`s
  public func setMessageIncomingAvatarSize(_ newSize: CGSize) {
    messageSizeCalculators().forEach { $0.incomingAvatarSize = newSize }
  }
  
  /// Set `outgoingAvatarSize` of all `MessageSizeCalculator`s
  public func setMessageOutgoingAvatarSize(_ newSize: CGSize) {
    messageSizeCalculators().forEach { $0.outgoingAvatarSize = newSize }
  }
  
  /// Set `incomingAvatarPosition` of all `MessageSizeCalculator`s
  public func setMessageIncomingAvatarPosition(_ newPosition: AvatarPosition) {
    messageSizeCalculators().forEach { $0.incomingAvatarPosition = newPosition }
  }
  
  /// Set `outgoingAvatarPosition` of all `MessageSizeCalculator`s
  public func setMessageOutgoingAvatarPosition(_ newPosition: AvatarPosition) {
    messageSizeCalculators().forEach { $0.outgoingAvatarPosition = newPosition }
  }
  
  /// Set `incomingMessagePadding` of all `MessageSizeCalculator`s
  public func setMessageIncomingMessagePadding(_ newPadding: NSEdgeInsets) {
    messageSizeCalculators().forEach { $0.incomingMessagePadding = newPadding }
  }
  
  /// Set `outgoingMessagePadding` of all `MessageSizeCalculator`s
  public func setMessageOutgoingMessagePadding(_ newPadding: NSEdgeInsets) {
    messageSizeCalculators().forEach { $0.outgoingMessagePadding = newPadding }
  }
  
  /// Set `incomingCellTopLabelAlignment` of all `MessageSizeCalculator`s
  public func setMessageIncomingCellTopLabelAlignment(_ newAlignment: LabelAlignment) {
    messageSizeCalculators().forEach { $0.incomingCellTopLabelAlignment = newAlignment }
  }
  
  /// Set `outgoingCellTopLabelAlignment` of all `MessageSizeCalculator`s
  public func setMessageOutgoingCellTopLabelAlignment(_ newAlignment: LabelAlignment) {
    messageSizeCalculators().forEach { $0.outgoingCellTopLabelAlignment = newAlignment }
  }
  
  /// Set `incomingMessageTopLabelAlignment` of all `MessageSizeCalculator`s
  public func setMessageIncomingMessageTopLabelAlignment(_ newAlignment: LabelAlignment) {
    messageSizeCalculators().forEach { $0.incomingMessageTopLabelAlignment = newAlignment }
  }
  
  /// Set `outgoingMessageTopLabelAlignment` of all `MessageSizeCalculator`s
  public func setMessageOutgoingMessageTopLabelAlignment(_ newAlignment: LabelAlignment) {
    messageSizeCalculators().forEach { $0.outgoingMessageTopLabelAlignment = newAlignment }
  }
  
  /// Set `incomingMessageBottomLabelAlignment` of all `MessageSizeCalculator`s
  public func setMessageIncomingMessageBottomLabelAlignment(_ newAlignment: LabelAlignment) {
    messageSizeCalculators().forEach { $0.incomingMessageBottomLabelAlignment = newAlignment }
  }
  
  /// Set `outgoingMessageBottomLabelAlignment` of all `MessageSizeCalculator`s
  public func setMessageOutgoingMessageBottomLabelAlignment(_ newAlignment: LabelAlignment) {
    messageSizeCalculators().forEach { $0.outgoingMessageBottomLabelAlignment = newAlignment }
  }
  
  /// Set `incomingAccessoryViewSize` of all `MessageSizeCalculator`s
  public func setMessageIncomingAccessoryViewSize(_ newSize: CGSize) {
    messageSizeCalculators().forEach { $0.incomingAccessoryViewSize = newSize }
  }
  
  /// Set `outgoingAvatarSize` of all `MessageSizeCalculator`s
  public func setMessageOutgoingAccessoryViewSize(_ newSize: CGSize) {
    messageSizeCalculators().forEach { $0.outgoingAccessoryViewSize = newSize }
  }
  
  /// Set `incomingAccessoryViewSize` of all `MessageSizeCalculator`s
  public func setMessageIncomingAccessoryViewPadding(_ newPadding: HorizontalEdgeInsets) {
    messageSizeCalculators().forEach { $0.incomingAccessoryViewPadding = newPadding }
  }
  
  /// Set `outgoingAvatarSize` of all `MessageSizeCalculator`s
  public func setMessageOutgoingAccessoryViewPadding(_ newPadding: HorizontalEdgeInsets) {
    messageSizeCalculators().forEach { $0.outgoingAccessoryViewPadding = newPadding }
  }
  
  /// Get all `MessageSizeCalculator`s
  open func messageSizeCalculators() -> [MessageSizeCalculator] {
    return [textMessageSizeCalculator, attributedTextMessageSizeCalculator, emojiMessageSizeCalculator, photoMessageSizeCalculator, videoMessageSizeCalculator, locationMessageSizeCalculator]
  }
  
}
