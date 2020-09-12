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
    
    let hostname = "imap.fastmail.com"
    let postal: Postal
    var emails: [EmailData] = []

    init(username: String, password: String) {
        self.postal = Postal(configuration: Configuration(hostname: hostname, port: 993, login: username, password: PasswordType.plain(password), connectionType: .tls, checkCertificateEnabled: true))
    }
    
    func fetchAllMessages() {
        emails.removeAll()
        postal.connect(timeout: Postal.defaultTimeout, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success:
                    self.postal.search("INBOX", filter: .all, completion: { result in
                        switch result {
                            case .success(let index):
                                self.fetchMails(by: index)
                            case .failure(let error):
                                print(error)
                        }
                    })
                case .failure(let error):
                    print(error)
            }
        })
    }
    
    private func fetchMails(by index: IndexSet) {
        self.postal.fetchMessages("INBOX", uids: index, flags: [.fullHeaders, .body, .internalDate], onMessage: { message in
                message.body?.allParts.forEach { part in
                    if part.mimeType.description == "text/plain", let from = message.header?.from.first, let date = message.internalDate, let subject = message.header?.subject, let bodyData = part.data?.decodedData {
                        self.emails.append(EmailData(senderName: from.displayName, senderEmail: from.email, date: date, headers: subject, body: String(decoding: bodyData, as: UTF8.self)))
                    }
                }
        }, onComplete: { error in
            print(error.debugDescription)
        })
    }
}
