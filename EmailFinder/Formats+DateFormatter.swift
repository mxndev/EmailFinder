//
//  Formats+DateFormatter.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 12/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let shortFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "rrrr-MM-dd"
        return dateFormatter
    }()
    
    static let onlyYear: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "rrrr"
        return dateFormatter
    }()
    
    static let onlyMonth: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter
    }()
    
    static let onlyDay: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter
    }()
}
