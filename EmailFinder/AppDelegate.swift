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
    static let emailAdress = "" // type your email here
    static let password = "" // type your password here
    static let synchronizeMode: DirectorySynchronizerMode = .sender // select mode

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // start synchronizer
        MailSynchronizerViewModel.instance.runSynchronizer()
        
        RunLoop.main.run()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
