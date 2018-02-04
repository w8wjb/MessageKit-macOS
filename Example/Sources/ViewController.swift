//
//  ViewController.swift
//  ChatExample
//
//  Created by Weston Bustraan on 03/02/2018.
//  Copyright © 2018 MessageKit-macOS. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let conversationViewController = ConversationViewController()
        addChildViewController(conversationViewController)
        
        conversationViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(conversationViewController.view)

        view.topAnchor.constraint(equalTo: conversationViewController.view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: conversationViewController.view.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: conversationViewController.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: conversationViewController.view.trailingAnchor).isActive = true
        
        
    }

}

