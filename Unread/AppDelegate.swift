//
//  AppDelegate.swift
//  NotificationTest
//
//  Created by Ke Sun on 11/28/15.
//  Copyright © 2015 Bleep Blop. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let query = NSMetadataQuery()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "queryUnreadMails", userInfo: nil, repeats: true)
        timer.fire()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func queryUnreadMails() {
        query.predicate = NSPredicate(fromMetadataQueryString: "kMDItemContentType == 'com.apple.mail.emlx'")
        query.searchScopes = [NSMetadataQueryUserHomeScope]
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "queryUpdated:",
            name: NSMetadataQueryDidFinishGatheringNotification,
            object: query)
        
        query.startQuery()
    }
    
    func queryUpdated(object: AnyObject) {
        print("Total mail count: \(query.results.count)")
        
        var i = 0
        for resultObject in query.results {
            let metadata = resultObject as! NSMetadataItem
            
//            for attribute in metadata.attributes {
//                print("\(attribute): \(resultObject.valueForAttribute(attribute))")
//            }
            
            if let read = metadata.valueForAttribute("com_apple_mail_read")?.boolValue {
                if !read { i++ }
            }
        }
        
        print("Total unread count: \(i)")
    }
}

