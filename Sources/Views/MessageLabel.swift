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

open class MessageLabel: NSTextView {
  
  // MARK: - Private Properties
  
  private lazy var rangesForDetectors: [DetectorType: [(NSRange, MessageTextCheckingType)]] = [:]
  
  private var isConfiguring: Bool = false
  
  // MARK: - Public Properties
  
  open weak var messageLabelDelegate: MessageLabelDelegate?
  
  open var enabledDetectors: [DetectorType] = [] {
    didSet {
      //            setTextStorage(attributedStringValue, shouldParse: true)
    }
  }
  
  var attributedStringValue: NSAttributedString {
    get {
      if let textStorage = self.textStorage {
        return textStorage as NSAttributedString
      }
      return NSAttributedString()
    }
    
    set {
      if let textStorage = self.textStorage {
        textStorage.setAttributedString(newValue)
      }
    }
  }
  
  open override var font: NSFont? {
    didSet {
      textStorage?.font = font
    }
  }
  
  private var attributesNeedUpdate = false
  
  public static var defaultAttributes: [NSAttributedString.Key: Any] = {
    return [
      NSAttributedString.Key.foregroundColor: NSColor.controlDarkShadowColor,
      NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
      NSAttributedString.Key.underlineColor: NSColor.controlDarkShadowColor
    ]
  }()
  
  open internal(set) var addressAttributes: [NSAttributedString.Key: Any] = defaultAttributes
  
  open internal(set) var dateAttributes: [NSAttributedString.Key: Any] = defaultAttributes
  
  open internal(set) var phoneNumberAttributes: [NSAttributedString.Key: Any] = defaultAttributes
  
  open internal(set) var urlAttributes: [NSAttributedString.Key: Any] = defaultAttributes
  
  public func setAttributes(_ attributes: [NSAttributedString.Key: Any], detector: DetectorType) {
    switch detector {
    case .phoneNumber:
      phoneNumberAttributes = attributes
    case .address:
      addressAttributes = attributes
    case .date:
      dateAttributes = attributes
    case .url:
      urlAttributes = attributes
    }
    if isConfiguring {
      attributesNeedUpdate = true
    } else {
      updateAttributes(for: [detector])
    }
  }
  
  // MARK: - Initializers
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  public override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
    super.init(frame: frameRect, textContainer: container)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.autoresizingMask = .none
    self.textContainerInset = NSZeroSize
    self.drawsBackground = false
    self.isEditable = false
    self.isSelectable = true
    
    if let textContainer = self.textContainer {
      textContainer.maximumNumberOfLines = 0
      textContainer.lineFragmentPadding = 0
    }
    
  }
  
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public Methods
  
  public func configure(block: () -> Void) {
    isConfiguring = true
    block()
    if attributesNeedUpdate {
      updateAttributes(for: enabledDetectors)
    }
    attributesNeedUpdate = false
    isConfiguring = false
    needsDisplay = true
  }
  
  // MARK: - Private Methods
  
  //  private func setTextStorage(_ newText: NSAttributedString?, shouldParse: Bool) {
  //
  //    //        guard let newText = newText, newText.length > 0 else {
  //    //            textStorage.setAttributedString(NSAttributedString())
  //    //            setNeedsDisplay()
  //    //            return
  //    //        }
  //    //
  //    //        let style = paragraphStyle(for: newText)
  //    //        let range = NSRange(location: 0, length: newText.length)
  //    //
  //    //        let mutableText = NSMutableAttributedString(attributedString: newText)
  //    //        mutableText.addAttribute(.paragraphStyle, value: style, range: range)
  //    //
  //    //        if shouldParse {
  //    //            rangesForDetectors.removeAll()
  //    //            let results = parse(text: mutableText)
  //    //            setRangesForDetectors(in: results)
  //    //        }
  //    //
  //    //        for (detector, rangeTuples) in rangesForDetectors {
  //    //            if enabledDetectors.contains(detector) {
  //    //                let attributes = detectorAttributes(for: detector)
  //    //                rangeTuples.forEach { (range, _) in
  //    //                    mutableText.addAttributes(attributes, range: range)
  //    //                }
  //    //            }
  //    //        }
  //    //
  //    //        let modifiedText = NSAttributedString(attributedString: mutableText)
  //    //        textStorage.setAttributedString(modifiedText)
  //    //
  //    //        if !isConfiguring { setNeedsDisplay() }
  //
  //  }
  
  private func paragraphStyle(for text: NSAttributedString) -> NSParagraphStyle {
    guard text.length > 0 else { return NSParagraphStyle() }
    
    var range = NSRange(location: 0, length: text.length)
    let existingStyle = text.attribute(.paragraphStyle, at: 0, effectiveRange: &range) as? NSMutableParagraphStyle
    let style = existingStyle ?? NSMutableParagraphStyle()
    
    //    style.lineBreakMode = lineBreakMode
    style.alignment = alignment
    
    return style
  }
  
  private func updateAttributes(for detectors: [DetectorType]) {
    
    guard attributedStringValue.length > 0 else { return }
    let mutableAttributedString = NSMutableAttributedString(attributedString: attributedStringValue)
    
    for detector in detectors {
      guard let rangeTuples = rangesForDetectors[detector] else { continue }
      
      for (range, _)  in rangeTuples {
        let attributes = detectorAttributes(for: detector)
        mutableAttributedString.addAttributes(attributes, range: range)
      }
      
      let updatedString = NSAttributedString(attributedString: mutableAttributedString)
      //            textStorage.setAttributedString(updatedString)
    }
  }
  
  private func detectorAttributes(for detectorType: DetectorType) -> [NSAttributedString.Key: Any] {
    
    switch detectorType {
    case .address:
      return addressAttributes
    case .date:
      return dateAttributes
    case .phoneNumber:
      return phoneNumberAttributes
    case .url:
      return urlAttributes
    }
    
  }
  
  private func detectorAttributes(for checkingResultType: NSTextCheckingResult.CheckingType) -> [NSAttributedString.Key: Any] {
    switch checkingResultType {
    case .address:
      return addressAttributes
    case .date:
      return dateAttributes
    case .phoneNumber:
      return phoneNumberAttributes
    case .link:
      return urlAttributes
    default:
      fatalError(MessageKitError.unrecognizedCheckingResult)
    }
  }
  
  // MARK: - Parsing Text
  
  private func parse(text: NSAttributedString) -> [NSTextCheckingResult] {
    guard enabledDetectors.isEmpty == false else { return [] }
    let checkingTypes = enabledDetectors.reduce(0) { $0 | $1.textCheckingType.rawValue }
    let detector = try? NSDataDetector(types: checkingTypes)
    let range = NSRange(location: 0, length: text.length)
    return detector?.matches(in: text.string, options: [], range: range) ?? []
  }
  
  private func setRangesForDetectors(in checkingResults: [NSTextCheckingResult]) {
    
    guard checkingResults.isEmpty == false else { return }
    
    for result in checkingResults {
      
      switch result.resultType {
      case .address:
        var ranges = rangesForDetectors[.address] ?? []
        let tuple: (NSRange, MessageTextCheckingType) = (result.range, .addressComponents(result.addressComponents))
        ranges.append(tuple)
        rangesForDetectors.updateValue(ranges, forKey: .address)
      case .date:
        var ranges = rangesForDetectors[.date] ?? []
        let tuple: (NSRange, MessageTextCheckingType) = (result.range, .date(result.date))
        ranges.append(tuple)
        rangesForDetectors.updateValue(ranges, forKey: .date)
      case .phoneNumber:
        var ranges = rangesForDetectors[.phoneNumber] ?? []
        let tuple: (NSRange, MessageTextCheckingType) = (result.range, .phoneNumber(result.phoneNumber))
        ranges.append(tuple)
        rangesForDetectors.updateValue(ranges, forKey: .phoneNumber)
      case .link:
        var ranges = rangesForDetectors[.url] ?? []
        let tuple: (NSRange, MessageTextCheckingType) = (result.range, .link(result.url))
        ranges.append(tuple)
        rangesForDetectors.updateValue(ranges, forKey: .url)
      default:
        fatalError("Received an unrecognized NSTextCheckingResult.CheckingType")
      }
      
    }
    
  }
  
  private func handleDate(_ date: Date) {
    messageLabelDelegate?.didSelectDate(date)
  }
  
  private func handleURL(_ url: URL) {
    messageLabelDelegate?.didSelectURL(url)
  }
  
  private func handlePhoneNumber(_ phoneNumber: String) {
    messageLabelDelegate?.didSelectPhoneNumber(phoneNumber)
  }
  
}

private enum MessageTextCheckingType {
  case addressComponents([NSTextCheckingKey: String]?)
  case date(Date?)
  case phoneNumber(String?)
  case link(URL?)
}
