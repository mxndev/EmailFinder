//
//  MailboxDownloaderViewModelMock.swift
//  EmailFinderTests
//
//  Created by Mikołaj Płachta on 16/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Foundation

class MailboxDownloaderViewModelMock: MailboxDownloaderViewModelBase {
    var delegate: MailboxDownloaderViewDelegate?
    var emails: [EmailData] = []
    
    init() {
        // init mock messsages
        emails.append(contentsOf: [
            EmailData(senderName: "Test1", senderEmail: "test1@fastmail.com", date: DateFormatter.shortFormat.date(from: "2020-07-22") ?? Date(), subject: "This is a test subject", body: "blabla"),
            EmailData(senderName: "Test1", senderEmail: "test1@fastmail.com", date: DateFormatter.shortFormat.date(from: "2020-07-22") ?? Date(), subject: "This is a test subject", body: "blabla2"),
            EmailData(senderName: "Test2", senderEmail: "test2@fastmail.com", date: DateFormatter.shortFormat.date(from: "2020-07-22") ?? Date(), subject: "This is a test subject", body: "blabla"),
            EmailData(senderName: "Test3", senderEmail: "test3@fastmail.com", date: DateFormatter.shortFormat.date(from: "2020-07-22") ?? Date(), subject: "This is a test subject", body: "blabla"),
            EmailData(senderName: "Test1", senderEmail: "test@fastmail.com", date: DateFormatter.shortFormat.date(from: "2020-08-22") ?? Date(), subject: "This is a test subject2", body: "blabla"),
            EmailData(senderName: "Test2", senderEmail: "test2@fastmail.com", date: DateFormatter.shortFormat.date(from: "2020-08-22") ?? Date(), subject: "This is a test subject2", body: "blabla"),
            EmailData(senderName: "Test2", senderEmail: "test2@fastmail.com", date: DateFormatter.shortFormat.date(from: "2020-08-23") ?? Date(), subject: "This is a test subject", body: "blabla"),
            EmailData(senderName: "Test2", senderEmail: "test2@fastmail.com", date: DateFormatter.shortFormat.date(from: "2020-08-24") ?? Date(), subject: "This is a test subject", body: "blabla"),
        ])
    }
    
    func connectToServer(fetchMails: Bool) {
        // not needed here
    }
    
    func fetchAllMessages(retry: Bool, semaphore: DispatchSemaphore?) {
        delegate?.emailsFetchedSuccessfully(semaphore: semaphore)
    }
}

extension MailboxDownloaderViewModelBase {
    static var mockInstance: MailboxDownloaderViewModelBase {
        guard let resolved = SharedContainer.sharedContainer.resolve(MailboxDownloaderViewModelBase.self) else {
            let manager = MailboxDownloaderViewModelMock()
            SharedContainer.sharedContainer.register(MailboxDownloaderViewModelBase.self) { [manager] _ in
                manager
            }
            return manager
        }
        return resolved
    }
}
