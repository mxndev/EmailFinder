//
//  MailboxDownloaderViewModelBase.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 11/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Foundation

protocol MailboxDownloaderViewModelBase {
    var delegate: MailboxDownloaderViewDelegate? { get set }
    
    func fetchAllMessages()
}

extension MailboxDownloaderViewModelBase {
    static var instance: MailboxDownloaderViewModelBase {
        guard let resolved = SharedContainer.sharedContainer.resolve(MailboxDownloaderViewModelBase.self) else {
            let manager = MailboxDownloaderViewModel(username: AppDelegate.emailAdress, password: AppDelegate.password)
            SharedContainer.sharedContainer.register(MailboxDownloaderViewModelBase.self) { [manager] _ in
                manager
            }
            return manager
        }
        return resolved
    }
}

protocol MailboxDownloaderViewDelegate: class {
    func emailsFetchedSuccessfully(emails: [EmailData])
}
