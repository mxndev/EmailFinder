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
    static let emailAdress = "" // type your email here
    static let password = "" // type your password here
    static let synchronizeMode: DirectorySynchronizerMode = .topics // select mode
    static let timeBetweenSyncCalls: Int = 3 // time in minutes
    static let exludedFolders: [String] = ["Sent", "Drafts", "Spam", "Trash", "Archive"] // excluded folders or subfolders - Sent & Drafts, because it belongs to sending functionality and SPAM, Trash & Archive because in my opinion that emails should be synchronized, but it can be changed easily

    var mailSynchronizer: MailSynchronizerController! = MailSynchronizerController(mailDownloader: MailboxDownloaderViewModel.instance, timeBetweenSyncCalls: AppDelegate.timeBetweenSyncCalls)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // connect to server
        MailboxDownloaderViewModel.instance.connectToServer(fetchMails: false)
        
        // start synchronizer
        mailSynchronizer.setSynchronizationMode(mode: AppDelegate.synchronizeMode)
        mailSynchronizer.runSynchronizer(semaphore: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
