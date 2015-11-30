//
//  AppDelegate.swift
//  NotificationTest
//
//  Created by Ke Sun on 11/28/15.
//  Copyright © 2015 Bleep Blop. All rights reserved.
//

// Icon from: http://www.flaticon.com/free-icon/mail-envelope_62032

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var statusItem: NSStatusItem!
    var darkMode: Bool = false
    
    let query = NSMetadataQuery()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // Check if OS is in light or dark mode.
        if let _ = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") {
            self.darkMode = true
        }
        
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.statusItem.image = self.darkMode ? NSImage(named: "mail-white.png") : NSImage(named: "mail-black.png")
        self.statusItem.image?.size = NSMakeSize(16.0, 16.0)
        self.statusItem.action = "itemClicked:"
        
        self.queryUnreadMails()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func queryUnreadMails() {
        query.predicate = NSPredicate(fromMetadataQueryString: "kMDItemContentType == 'com.apple.mail.emlx'")
        query.searchScopes = [NSMetadataQueryUserHomeScope]
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "queryUpdated:",
            name: NSMetadataQueryDidFinishGatheringNotification,
            object: query)
        
        query.startQuery()
    }
    
    func queryUpdated(object: AnyObject) {
        query.stopQuery()
        
        print("Total count: \(query.results.count)")

        var hasUnread = false;
        let array = query.results as NSArray
        array.enumerateObjectsWithOptions(NSEnumerationOptions.Concurrent, usingBlock: {(obj, idx, stop) -> Void in
            let metadata = obj as! NSMetadataItem
            
            if let read = metadata.valueForAttribute("com_apple_mail_read")?.boolValue {
                if !read { hasUnread = true }
            }
        })
        
        if hasUnread {
            self.statusItem.image = self.darkMode ? NSImage(named: "letter-white.png") : NSImage(named: "letter-black.png")
            self.statusItem.image?.size = NSMakeSize(16.0, 16.0)
        } else {
            self.statusItem.image = self.darkMode ? NSImage(named: "mail-white.png") : NSImage(named: "mail-black.png")
            self.statusItem.image?.size = NSMakeSize(16.0, 16.0)
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(30.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.queryUnreadMails()
        }
    }
    
    func itemClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().launchApplication("Mail")
    }
}

