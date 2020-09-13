//
//  MailSynchronizerViewModelBase.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 12/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Foundation

protocol MailSynchronizerViewModelBase {
    func runSynchronizer()
}

extension MailSynchronizerViewModelBase {
    static var instance: MailSynchronizerViewModelBase {
        guard let resolved = SharedContainer.sharedContainer.resolve(MailSynchronizerViewModelBase.self) else {
            let manager = MailSynchronizerViewModel(mailDownloader: MailboxDownloaderViewModel.instance, synchronizeMode: AppDelegate.synchronizeMode)
            SharedContainer.sharedContainer.register(MailSynchronizerViewModelBase.self) { [manager] _ in
                manager
            }
            return manager
        }
        return resolved
    }
}
