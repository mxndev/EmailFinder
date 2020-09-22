//
//  MailSynchronizerController.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 12/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Foundation

enum DirectorySynchronizerMode {
    case timeline
    case sender
    case topics
}

class MailSynchronizerController {
    var mailboxDownloader: MailboxDownloaderViewModelBase
    var startTimestamp: Date = Date()
    let fileManager = FileManager.default
    var mode: DirectorySynchronizerMode = .timeline
    var timeBetweenSyncCalls: Int = 0

    init(mailDownloader: MailboxDownloaderViewModelBase, timeBetweenSyncCalls: Int) {
        self.mailboxDownloader = mailDownloader
        self.mailboxDownloader.delegate = self
        self.timeBetweenSyncCalls = timeBetweenSyncCalls
    }
    
    // use semaphore for prepare ability to proper testing
    func runSynchronizer(semaphore: DispatchSemaphore?) {
        DispatchQueue.global(qos: .background).async {
            self.mailboxDownloader.fetchAllMessages(retry: true, semaphore: semaphore)
        }
    }
    
    func setSynchronizationMode(mode: DirectorySynchronizerMode) {
        self.mode = mode
    }
    
    private func generateFiles(for email: EmailData, siblingIndex: Int?) {
        if let desktopDirectory = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            var fileDirectory: URL
            
            switch self.mode {
                case .sender:
                    fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/sender/\(email.senderEmail)/")
                case .timeline:
                    fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/timeline/\(email.year)/\(email.month)/\(email.day)/")
                case .topics:
                    fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/topics/\(email.folderName)/")
            }
            do {
                if !fileManager.fileExists(atPath: fileDirectory.path) {
                    try fileManager.createDirectory(atPath: fileDirectory.path, withIntermediateDirectories: true, attributes: nil)
                }
                
                if let indexOfSigling = siblingIndex {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName)-\(indexOfSigling+1).txt")
                } else {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName).txt")
                }
                
                let emailData = "From: \(email.senderName) (\(email.senderEmail)) - \(DateFormatter.shortFormat.string(from: email.date))\n\(email.subject)\n\(email.body)"
                try emailData.write(to: fileDirectory, atomically: true, encoding: .utf8)
            } catch {
                print(error)
            }
        }
    }
    
    // siblings - files with similar names in the same folder
    func generateSiblingsForEmails() -> [Int?] {
        var siblings: [(EmailData, Int?)] = []
        mailboxDownloader.emails.forEach { email in
            switch self.mode {
                case .sender:
                    siblings.append((email, mailboxDownloader.emails.filter({ $0.fileName == email.fileName && $0.senderEmail == email.senderEmail }).count > 1 ? siblings.filter({ $0.0.fileName == email.fileName && $0.0.senderEmail == email.senderEmail }).count : nil))
                case .timeline:
                    siblings.append((email, mailboxDownloader.emails.filter({ $0.fileName == email.fileName && $0.year == email.year && $0.month == email.month && $0.day == email.day }).count > 1 ? siblings.filter({ $0.0.fileName == email.fileName && $0.0.year == email.year && $0.0.month == email.month && $0.0.day == email.day }).count : nil))
                case .topics:
                    siblings.append((email, mailboxDownloader.emails.filter({ $0.fileName == email.fileName && $0.folderName == email.folderName }).count > 1 ? siblings.filter({ $0.0.fileName == email.fileName && $0.0.folderName == email.folderName }).count : nil))
            }
        }
        return siblings.map { ($0.1) }
    }
    
    private func clearFilesWithOldTimestamp() {
        if let desktopDirectory = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            let fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/")
            
            do {
                let resourceKeys : [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey]
                if let enumerator = fileManager.enumerator(at: fileDirectory, includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil) {
                    for case let fileURL as URL in enumerator {
                        let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                        if !(resourceValues.isDirectory ?? true), let modificationDate = resourceValues.contentModificationDate, modificationDate < startTimestamp {
                            try fileManager.removeItem(at: fileURL)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func clearEmptyDirectories() {
        var folderRemoved = true
        while folderRemoved { // due to limitation about removing empty subdirectories, create a loop, that will run until none of folder will be removed
            folderRemoved = false
            if let desktopDirectory = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
                let fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/")
                
                do {
                    let resourceKeys : [URLResourceKey] = [.isDirectoryKey]
                    if let enumerator = fileManager.enumerator(at: fileDirectory, includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil) {
                        for case let fileURL as URL in enumerator {
                            let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                            if resourceValues.isDirectory ?? false {
                                let content = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                                if content.filter({ $0 != ".DS_Store" }).count == 0 {
                                    folderRemoved = true
                                    try fileManager.removeItem(atPath: fileURL.path)
                                }
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension MailSynchronizerController: MailboxDownloaderViewDelegate {
    func emailsFetchedSuccessfully(semaphore: DispatchSemaphore?) {
        startTimestamp = Date()
        let siblings = generateSiblingsForEmails()
        for (index, element) in mailboxDownloader.emails.enumerated() {
            generateFiles(for: element, siblingIndex: siblings[index])
        }
        
        // remove old files & empty directories for both modes
        clearFilesWithOldTimestamp()
        clearEmptyDirectories()
        
        semaphore?.signal()
        
        // schedule next sync
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(timeBetweenSyncCalls*60)) {
            self.mailboxDownloader.fetchAllMessages(retry: true, semaphore: nil)
        }
    }
}
