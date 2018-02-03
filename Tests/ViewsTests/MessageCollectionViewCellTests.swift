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

import XCTest
@testable import MessageKit_macOS

class MessageCollectionViewCellTests: XCTestCase {

    var cell: MessageCollectionViewItem!
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)

    override func setUp() {
        super.setUp()
        cell = MessageCollectionViewItem(frame: frame)
    }

    override func tearDown() {
        cell = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(cell.view.autoresizingMask, [.width, .height])
        XCTAssert(cell.view.subviews.contains(cell.cellTopLabel))
        XCTAssert(cell.view.subviews.contains(cell.cellBottomLabel))
        XCTAssert(cell.view.subviews.contains(cell.avatarView))
        XCTAssert(cell.view.subviews.contains(cell.messageContainerView))

    }

    func testMessageContainerViewPropertiesSetup() {
        XCTAssertTrue(cell.messageContainerView.layer!.masksToBounds)
    }

    func testPrepareForReuse() {
        cell.prepareForReuse()
        XCTAssertEqual(cell.cellTopLabel.stringValue, "")
        XCTAssertEqual(cell.cellTopLabel.attributedStringValue, NSAttributedString())
        XCTAssertEqual(cell.cellBottomLabel.stringValue, "")
        XCTAssertEqual(cell.cellBottomLabel.attributedStringValue, NSAttributedString())
    }

    func testApplyLayoutAttributes() {
        let layoutAttributes = MessagesCollectionViewLayoutAttributes()
        cell.apply(layoutAttributes)

        XCTAssertEqual(cell.avatarView.frame, layoutAttributes.frame)
        XCTAssertEqual(cell.messageContainerView.frame, layoutAttributes.messageContainerFrame)
        XCTAssertEqual(cell.cellTopLabel.frame, layoutAttributes.topLabelFrame)
        XCTAssertEqual(cell.cellBottomLabel.frame, layoutAttributes.bottomLabelFrame)
    }

}

extension MessageCollectionViewCellTests {

    fileprivate class MockMessagesDisplayDelegate: MessagesDisplayDelegate {
        
        func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
            return LocationMessageSnapshotOptions()
        }
    }

}
