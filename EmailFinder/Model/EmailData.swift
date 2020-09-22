//
//  EmailData.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 11/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Foundation

struct EmailData {
    let folderName: String
    let senderName: String
    let senderEmail: String
    let date: Date
    let subject: String
    let body: String
    
    var identifier: String {
        return "\(senderEmail)-\(subject)-\(DateFormatter.shortFormat.string(from: date))"
    }
    
    var fileName: String {
        return "\(senderEmail)-\(subject)"
    }
    
    var day: String {
        return DateFormatter.onlyDay.string(from: date)
    }
    
    var month: String {
        return DateFormatter.onlyMonth.string(from: date)
    }
    
    var year: String {
        return DateFormatter.onlyYear.string(from: date)
    }
}
