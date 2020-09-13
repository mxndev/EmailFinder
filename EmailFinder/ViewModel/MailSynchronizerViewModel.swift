//
//  MailSynchronizerViewModel.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 12/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Foundation

enum DirectorySynchronizerMode {
    case timeline
    case sender
}

class MailSynchronizerViewModel: MailSynchronizerViewModelBase {
    var mailboxDownloader: MailboxDownloaderViewModelBase
    var startTimestamp: Date = Date()
    let fileManager = FileManager.default
    let mode: DirectorySynchronizerMode

    init(mailDownloader: MailboxDownloaderViewModelBase, synchronizeMode: DirectorySynchronizerMode) {
        self.mailboxDownloader = mailDownloader
        self.mode = synchronizeMode
        self.mailboxDownloader.delegate = self
    }
    
    func runSynchronizer() {
        DispatchQueue.global(qos: .background).async {
            self.mailboxDownloader.fetchAllMessages()
        }
    }
    
    private func generateFiles(for mode: DirectorySynchronizerMode, email: EmailData) {
        if let desktopDirectory = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            let amountOfFiles = amountOfSimilarNames(for: email, mode: mode)
            var fileDirectory: URL
            
            switch mode {
                case .sender:
                    fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/sender/\(email.senderEmail)/")
                case .timeline:
                    fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/timeline/\(email.year)/\(email.month)/\(email.day)/")
            }
            do {
                if !FileManager.default.fileExists(atPath: fileDirectory.absoluteString.replacingOccurrences(of: "file://", with: "")) {
                    try FileManager.default.createDirectory(atPath: fileDirectory.absoluteString.replacingOccurrences(of: "file://", with: ""), withIntermediateDirectories: true, attributes: nil)
                }
                
                if amountOfFiles > 0 {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName)-\(amountOfFiles+1).txt")
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
    
    private func amountOfSimilarNames(for email: EmailData, mode: DirectorySynchronizerMode) -> Int {
        if let desktopDirectory = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            let fileDirectory: URL
            switch mode {
                case .sender:
                    fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/sender/\(email.senderEmail)/")
                case .timeline:
                    fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/timeline/\(email.year)/\(email.month)/\(email.day)/")
            }
            
            do {
                if !FileManager.default.fileExists(atPath: fileDirectory.absoluteString.replacingOccurrences(of: "file://", with: "")) {
                    try FileManager.default.createDirectory(atPath: fileDirectory.absoluteString.replacingOccurrences(of: "file://", with: ""), withIntermediateDirectories: true, attributes: nil)
                }
                
                let directoryContents = try FileManager.default.contentsOfDirectory(at: fileDirectory, includingPropertiesForKeys: nil)
                return directoryContents.filter({ $0.absoluteString.contains(email.fileName) }).count
            } catch {
                print(error)
            }
        }
        return 0
    }
    
    private func clearFilesWithOldTimestamp() {
        if let desktopDirectory = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            let fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/")
            
            do {
                let resourceKeys : [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey]
                let enumerator = fileManager.enumerator(at: fileDirectory, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles], errorHandler: nil)!

                for case let fileURL as URL in enumerator {
                    let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                    if !(resourceValues.isDirectory ?? true), let modificationDate = resourceValues.contentModificationDate, modificationDate < startTimestamp {
                        try fileManager.removeItem(at: fileURL)
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
                    if let enumerator = fileManager.enumerator(at: fileDirectory, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles], errorHandler: nil) {
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

extension MailSynchronizerViewModel: MailboxDownloaderViewDelegate {
    func emailsFetchedSuccessfully(emails: [EmailData]) {
        startTimestamp = Date()
        emails.forEach {
            generateFiles(for: self.mode, email: $0)
        }
        
        // remove old files & empty directories for both modes
        clearFilesWithOldTimestamp()
        clearEmptyDirectories()
        
        // schedule next sync
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + (3*60)) {
            self.mailboxDownloader.fetchAllMessages()
        }
    }
}
