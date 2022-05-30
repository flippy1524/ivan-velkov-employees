//
//  Extensions.swift
//  EmployeesSirma
//
//  Created by Ivan Velkov on 29.5.22.
//

import Foundation

extension String {
    func formattedFromDate(format: String) -> Date?{
        let date = DateManager.shared.date(from: self)
        return date
    }
    
    func formattedDateTo(format: String) -> Date?{
        guard self != "NULL" else {
            return Date()
        }
        
        let date = DateManager.shared.date(from: self)
        return date
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day!
    }
}
