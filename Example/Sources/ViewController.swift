//
//  ViewController.swift
//  ChatExample
//
//  Created by Weston Bustraan on 03/02/2018.
//  Copyright © 2018 MessageKit-macOS. All rights reserved.
//

import AppKit
import MessageKit_macOS

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let conversationViewController = ConversationViewController()
        addChildViewController(conversationViewController)
        
        conversationViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(conversationViewController.view)
        
        let messageInputBar = GrowingTextView()
        messageInputBar.textContainerInset = NSSize(width: 4, height: 4)
        messageInputBar.isRichText = false
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.wantsLayer = true
        messageInputBar.allowsImageEditing = true
        messageInputBar.importsGraphics = true
        messageInputBar.layer?.borderWidth = 1
        messageInputBar.layer?.borderColor = NSColor.black.cgColor
        messageInputBar.layer?.cornerRadius = 8
        
        view.addSubview(messageInputBar)
        
        //messageInputBar.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true

        //let messageInputBar = MessageInputBar()
        //messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(messageInputBar)

        view.topAnchor.constraint(equalTo: conversationViewController.view.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: conversationViewController.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: conversationViewController.view.trailingAnchor).isActive = true

        conversationViewController.view.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor, constant: -8).isActive = true
//        view.bottomAnchor.constraint(equalTo: conversationViewController.view.bottomAnchor).isActive = true
//
//        view.topAnchor.constraint(equalTo: messageInputView.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: -8).isActive = true
        view.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: 8).isActive = true
        view.bottomAnchor.constraint(equalTo: messageInputBar.bottomAnchor, constant: 8).isActive = true
        
        //messageInputBar.delegate = conversationViewController
        
    }

}

