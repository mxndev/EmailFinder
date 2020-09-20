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
    var emails: [EmailData] { get set }

    func connectToServer(fetchMails: Bool)
    func fetchAllMessages(retry: Bool, semaphore: DispatchSemaphore?)
}

protocol MailboxDownloaderViewDelegate: class {
    func emailsFetchedSuccessfully(semaphore: DispatchSemaphore?)
}
