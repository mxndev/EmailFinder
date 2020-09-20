//
//  MailboxDownloaderViewModel.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 11/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Foundation
import Postal

class MailboxDownloaderViewModel: MailboxDownloaderViewModelBase {
    weak var delegate: MailboxDownloaderViewDelegate?

    let hostname = "imap.fastmail.com"
    let postal: Postal
    var emails: [EmailData] = []

    init(username: String, password: String) {
        self.postal = Postal(configuration: Configuration(hostname: hostname, port: 993, login: username, password: PasswordType.plain(password), connectionType: .tls, checkCertificateEnabled: true))
    }
    
    func connectToServer(fetchMails: Bool) {
        postal.connect(timeout: Postal.defaultTimeout, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success:
                    if fetchMails { self.fetchAllMessages(retry: false, semaphore: nil) }
                case .failure(let error):
                    print(error)
            }
        })
    }
    
    func fetchAllMessages(retry: Bool, semaphore: DispatchSemaphore?) {
        emails.removeAll()
        postal.search("INBOX", filter: .all, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let index):
                    self.fetchMails(by: index, semaphore: semaphore)
                case .failure(let error):
                    // if first attempt try to connect and fetch data
                    if retry { self.connectToServer(fetchMails: true) }
                    print(error)
            }
        })
    }
    
    private func fetchMails(by index: IndexSet, semaphore: DispatchSemaphore?) {
        self.postal.fetchMessages("INBOX", uids: index, flags: [.fullHeaders, .body, .internalDate], onMessage: { message in
                message.body?.allParts.forEach { part in
                    if part.mimeType.description == "text/plain", let from = message.header?.from.first, let date = message.internalDate, let subject = message.header?.subject, let bodyData = part.data?.decodedData {
                        self.emails.append(EmailData(senderName: from.displayName, senderEmail: from.email, date: date, subject: subject, body: String(decoding: bodyData, as: UTF8.self)))
                    }
                }
        }, onComplete: { _ in
            self.delegate?.emailsFetchedSuccessfully(semaphore: semaphore)
        })
    }
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
