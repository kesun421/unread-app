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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Check if OS is in light or dark mode.
        if let _ = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") {
            self.darkMode = true
        }
        
        self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        self.statusItem.image = self.darkMode ? NSImage(named: "mail-white.png") : NSImage(named: "mail-black.png")
        self.statusItem.image?.size = NSMakeSize(16.0, 16.0)
        self.statusItem.action = #selector(AppDelegate.itemClicked(_:))
        
        self.queryUnreadMails()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func queryUnreadMails() {
        query.predicate = NSPredicate(fromMetadataQueryString: "kMDItemContentType == 'com.apple.mail.emlx'")
        query.searchScopes = [NSMetadataQueryUserHomeScope]
        
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(AppDelegate.queryUpdated(_:)),
            name: NSNotification.Name.NSMetadataQueryDidFinishGathering,
            object: query)
        
        query.start()
    }
    
    func queryUpdated(_ object: AnyObject) {
        query.stop()
        
        print("Total count: \(query.results.count)")

        var hasUnread = false;
        let array = query.results as NSArray
        array.enumerateObjects(options: NSEnumerationOptions.concurrent, using: {(obj, idx, stop) -> Void in
            let metadata = obj as! NSMetadataItem
            
            if let read = (metadata.value(forAttribute: "com_apple_mail_read") as AnyObject).boolValue {
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
        
        let delayTime = DispatchTime.now() + Double(Int64(30.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.queryUnreadMails()
        }
    }
    
    func itemClicked(_ sender: AnyObject) {
        NSWorkspace.shared().launchApplication("Mail")
    }
}

