//
//  DateManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 17.09.23.
//

import Foundation

class DateManager: ObservableObject {
    @Published var currentMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var currentYear: Int = Calendar.current.component(.year, from: Date())
    
    func getMonthFromDate(date: Date) -> Int {
        let month = Calendar.current.component(.month, from: date)
        return month
    }
    
    func getYearFromDate(date: Date) -> Int {
        let year = Calendar.current.component(.year, from: date)
        return year
    }
    
    func formatDate(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func getMonthName(month: Int) -> String {
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        return months[month-1]
    }
    
    func getDaysInCurrentMonth() -> [Date] {
        let calendar = Calendar.current
        let currentDate = Date()
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        
        var dates: [Date] = []
        
        for day in range.lowerBound..<range.upperBound {
            let components = DateComponents(year: year, month: month, day: day)
            if let date = calendar.date(from: components) {
                dates.append(date)
            }
        }

        return dates
    }
}
