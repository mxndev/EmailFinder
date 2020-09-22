//
//  EmailFinderTests.swift
//  EmailFinderTests
//
//  Created by Mikołaj Płachta on 05/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import XCTest
@testable import EmailFinder

class EmailFinderTests: XCTestCase {
    var mailSynchronizer: MailSynchronizerController?

    override func setUpWithError() throws {
        // initialize synchronizers
        mailSynchronizer = MailSynchronizerController(mailDownloader: MailboxDownloaderViewModelMock.mockInstance, timeBetweenSyncCalls: 3)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSiblingsForTimelineMode() throws {
        let properValues: [Int?] = [0, 1, nil, nil, nil, nil, nil, nil]
        mailSynchronizer?.setSynchronizationMode(mode: .timeline)
        let testValues = mailSynchronizer?.generateSiblingsForEmails()
        XCTAssert(testValues == properValues)
    }
    
    func testSiblingsForSenderMode() throws {
        let properValues: [Int?] = [0, 1, 0, nil, nil, nil, 1, 2]
        mailSynchronizer?.setSynchronizationMode(mode: .sender)
        let testValues = mailSynchronizer?.generateSiblingsForEmails()
        XCTAssert(testValues == properValues)
    }
    
    func testSiblingsForTopicsMode() throws {
        let properValues: [Int?] = [nil, nil, nil, nil, nil, nil, 0, 1]
        mailSynchronizer?.setSynchronizationMode(mode: .topics)
        let testValues = mailSynchronizer?.generateSiblingsForEmails()
        XCTAssert(testValues == properValues)
    }
    
    func testFilesStructureForTimelineMode() throws {
        let startTimestamp = Date()
        mailSynchronizer?.setSynchronizationMode(mode: .timeline)
        let semaphore = DispatchSemaphore(value: 0)
        mailSynchronizer?.runSynchronizer(semaphore: semaphore)
        semaphore.wait()
        let siblings = mailSynchronizer?.generateSiblingsForEmails()
        if let desktopDirectory = mailSynchronizer?.fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first, let emails = mailSynchronizer?.mailboxDownloader.emails {
            var listOfFiles: [Bool] = []
            for (index, email) in emails.enumerated() {
                var fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/timeline/\(email.year)/\(email.month)/\(email.day)/")
                
                if let indexOfSigling = siblings?[index] {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName)-\(indexOfSigling+1).txt")
                } else {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName).txt")
                }
                
                listOfFiles.append(mailSynchronizer?.fileManager.fileExists(atPath: fileDirectory.path) ?? false)
            }
            let oldFiles = checkAmountOfOldFiles(startTimestamp: startTimestamp)
            XCTAssert((listOfFiles.filter({ $0 == true }).count == emails.count) && (oldFiles == 0))
        } else {
            XCTAssert(false)
        }
    }

    func testFilesStructureForSenderMode() throws {
        let startTimestamp = Date()
        mailSynchronizer?.setSynchronizationMode(mode: .sender)
        let semaphore = DispatchSemaphore(value: 0)
        mailSynchronizer?.runSynchronizer(semaphore: semaphore)
        semaphore.wait()
        let siblings = mailSynchronizer?.generateSiblingsForEmails()
        if let desktopDirectory = mailSynchronizer?.fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first, let emails = mailSynchronizer?.mailboxDownloader.emails {
            var listOfFiles: [Bool] = []
            for (index, email) in emails.enumerated() {
                var fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/sender/\(email.senderEmail)/")
                
                if let indexOfSigling = siblings?[index] {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName)-\(indexOfSigling+1).txt")
                } else {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName).txt")
                }
                
                listOfFiles.append(mailSynchronizer?.fileManager.fileExists(atPath: fileDirectory.path) ?? false)
            }
            let oldFiles = checkAmountOfOldFiles(startTimestamp: startTimestamp)
            XCTAssert((listOfFiles.filter({ $0 == true }).count == emails.count) && (oldFiles == 0))
        } else {
            XCTAssert(false)
        }
    }
    
    func testFilesStructureForTopicsMode() throws {
        let startTimestamp = Date()
        mailSynchronizer?.setSynchronizationMode(mode: .topics)
        let semaphore = DispatchSemaphore(value: 0)
        mailSynchronizer?.runSynchronizer(semaphore: semaphore)
        semaphore.wait()
        let siblings = mailSynchronizer?.generateSiblingsForEmails()
        if let desktopDirectory = mailSynchronizer?.fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first, let emails = mailSynchronizer?.mailboxDownloader.emails {
            var listOfFiles: [Bool] = []
            for (index, email) in emails.enumerated() {
                var fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/topics/\(email.folderName)/")
                
                if let indexOfSigling = siblings?[index] {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName)-\(indexOfSigling+1).txt")
                } else {
                    fileDirectory = fileDirectory.appendingPathComponent("\(email.fileName).txt")
                }
                
                listOfFiles.append(mailSynchronizer?.fileManager.fileExists(atPath: fileDirectory.path) ?? false)
            }
            let oldFiles = checkAmountOfOldFiles(startTimestamp: startTimestamp)
            XCTAssert((listOfFiles.filter({ $0 == true }).count == emails.count) && (oldFiles == 0))
        } else {
            XCTAssert(false)
        }
    }

    func checkAmountOfOldFiles(startTimestamp: Date) -> Int {
        if let desktopDirectory = mailSynchronizer?.fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            let fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/")

            do {
                let resourceKeys : [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey]
                if let enumerator = mailSynchronizer?.fileManager.enumerator(at: fileDirectory, includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil) {
                    var index = 0
                    for case let fileURL as URL in enumerator {
                        let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                        if !(resourceValues.isDirectory ?? true), let modificationDate = resourceValues.contentModificationDate, modificationDate < startTimestamp {
                            index += 1
                        }
                    }
                    return index
                }
            } catch {
                print(error)
            }
        }
        return -1
    }
    
    func testAmountOfEmptyDirectories() throws {
        var amountOfDirectories = 0
        if let desktopDirectory = mailSynchronizer?.fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            let fileDirectory = desktopDirectory.appendingPathComponent("EmailsFinder/")
            
            do {
                let resourceKeys : [URLResourceKey] = [.isDirectoryKey]
                if let enumerator = mailSynchronizer?.fileManager.enumerator(at: fileDirectory, includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil) {
                    for case let fileURL as URL in enumerator {
                        let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                        if resourceValues.isDirectory ?? false {
                            if let content = try mailSynchronizer?.fileManager.contentsOfDirectory(atPath: fileURL.path) {
                                if content.filter({ $0 != ".DS_Store" }).count == 0 {
                                    amountOfDirectories += 1
                                }
                            }
                        }
                    }
                    XCTAssert(amountOfDirectories == 0)
                } else {
                    XCTAssert(false)
                }
            } catch {
                XCTAssert(false)
            }
        } else {
            XCTAssert(false)
        }
    }
}
