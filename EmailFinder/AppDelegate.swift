//
//  AppDelegate.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 05/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // config
    static let emailAdress = "golemtask@fastmail.com" // type your email here
    static let password = "r7dwpfztch9l88uf" // type your password here
    static let synchronizeMode: DirectorySynchronizerMode = .sender // select mode

    var mailSynchronizer: MailSynchronizerController! = MailSynchronizerController(mailDownloader: MailboxDownloaderViewModel.instance)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // connect to server
        MailboxDownloaderViewModel.instance.connectToServer(fetchMails: false)
        
        // start synchronizer
        mailSynchronizer.setSynchronizationMode(mode: AppDelegate.synchronizeMode)
        mailSynchronizer.runSynchronizer(semaphore: nil)
        
        RunLoop.main.run()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
