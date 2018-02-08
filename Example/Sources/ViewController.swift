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
        
        let messageInputBar = MessageInputBar()
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputBar)

        view.topAnchor.constraint(equalTo: conversationViewController.view.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: conversationViewController.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: conversationViewController.view.trailingAnchor).isActive = true

        conversationViewController.view.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor).isActive = true
//        view.bottomAnchor.constraint(equalTo: conversationViewController.view.bottomAnchor).isActive = true
//
//        view.topAnchor.constraint(equalTo: messageInputView.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: messageInputBar.bottomAnchor).isActive = true
        
        messageInputBar.delegate = conversationViewController
        
    }

}

