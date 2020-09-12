//
//  AppDelegate.swift
//  EmailFinder
//
//  Created by Mikołaj on 05/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        //t9m4yzcykds8xqga
        
        MailboxDownloaderViewModel.instance.fetchAllMessages()
        
//        RunLoop.main.run()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}
