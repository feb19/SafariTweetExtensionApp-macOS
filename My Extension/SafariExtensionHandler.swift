//
//  SafariExtensionHandler.swift
//  My Extension
//
//  Created by Nobuhiro Takahashi on 2018/07/03.
//  Copyright © 2018年 Nobuhiro Takahashi. All rights reserved.
//

import SafariServices
import Cocoa

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
        
        window.getActiveTab { (tab) in
            NSLog("gotActiveTab")
            tab?.getActivePage(completionHandler: { (page) in
                NSLog("gotActivePage")
                page?.getPropertiesWithCompletionHandler({ (properties) in
                    NSLog("gotProperties")
                    NSLog("\(String(describing: properties?.title))")
                    NSLog("\(String(describing: properties?.url))")
                    if properties?.url != nil && properties?.title != nil {
                        let escapedTitle = properties?.title?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                        let tweetURLString = "https://twitter.com/share?url=\((properties?.url!)!)&text=\((escapedTitle)!)"
                        if let tweetURL = URL(string: tweetURLString) {
                            window.openTab(with: tweetURL, makeActiveIfPossible: true, completionHandler: nil)
                        }
                    }
                })
            })
        }
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
