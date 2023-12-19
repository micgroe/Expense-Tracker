//
//  CategoryManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 30.11.23.
//

import Foundation
import SwiftUI

class CategoryManager: ObservableObject {
//    let categories: [String] = ["House", "Travel", "Grocery", "Gaming", "Car", "Restaurant", "Sports", "Alcohol"]
    
    let categoryIcons: [String: String] = [
        "House": "house.fill",
        "Travel": "airplane",
        "Grocery": "cart.fill",
        "Gaming": "gamecontroller.fill",
        "Car": "car.fill",
        "Restaurant": "fork.knife",
        "Sports": "figure.run",
        "Alcohol": "wineglass"
    ]
    
    @Published var categorySums: [String: Double] = [:]
    @Published var categoryLimits: [String: Double] = [:]
    
    @Published var categories: [Category] = []
    
    init() {
        loadCategorySums()
        loadCategoryLimits()
    }
    
    func addCategorySum(name: String, amount: Double) {
        categorySums[name, default: 0] += amount
        saveCategorySums()
    }
    
    func getCurrentMonthCategories(moneyManager: MoneyManager, category: String) -> [Transaction] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        let filteredExpenses = moneyManager.transactions.filter { transaction in
            let components = calendar.dateComponents([.month, .year], from: transaction.date)
            return transaction.category == category && components.month == currentMonth && components.year == currentYear
        }
        return filteredExpenses
    }
    
    func getCurrentMonthCategorySum(moneyManager: MoneyManager, category: String) -> Double {
        let filteredExpenses = getCurrentMonthCategories(moneyManager: moneyManager, category: category)
        
        var sum = 0.0
        for expense in filteredExpenses {
            sum += expense.amount
        }
        return sum
    }
    
    func getSelectedMonthCategories(moneyManager: MoneyManager, category: String, month: Int, year: Int) -> [Transaction] {
        let filteredExpenses = moneyManager.transactions.filter { transaction in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month, .year], from: transaction.date)
            return month == components.month && year == components.year && category == transaction.category
        }
        return filteredExpenses
    }
    
    func getSelectedMonthCategorySum(moneyManager: MoneyManager, category: String, month: Int, year: Int) -> Double {
        let filteredExpenses = getSelectedMonthCategories(moneyManager: moneyManager, category: category, month: month, year: year)
        
        var sum = 0.0
        for expense in filteredExpenses {
            sum += expense.amount
        }
        return sum
    }
    
    func calcLimitPercentage(moneyManager: MoneyManager, category: String, limit: Double) -> Double {
        let currentAmount = getCurrentMonthCategorySum(moneyManager: moneyManager, category: category)
        let percentage = currentAmount / limit
        return percentage
    }
    
    func addCategoryLimit(category: String, limit: Double) {
        categoryLimits[category] = limit
        saveCategoryLimits()
    }
    
    func removeCategoryLimit(category: String) {
        categoryLimits.removeValue(forKey: category)
        saveCategoryLimits()
    }
    
    func updateCategoryLimit(category: String, newLimit: Double) {
        categoryLimits[category] = newLimit
        saveCategoryLimits()
    }
    
    func getRemainingLimit(maxLimit: Double, currentLimit: Double) -> Double {
        let remainingLimit = maxLimit - currentLimit
        return remainingLimit
    }
    
    func getLineColor(currentLimit: Double, category: String) -> Color {
        let percentage = currentLimit / categoryLimits[category]!
        if percentage <= 0.33 {
            return Color.orange
        } else if percentage > 0.33 && percentage <= 0.67 {
            return Color.yellow
        } else if percentage > 0.67 && percentage <= 1 {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    private func loadCategorySums() {
        if let savedCategoryData = UserDefaults.standard.data(forKey: "CategorySums"),
           let savedCategories = try? JSONDecoder().decode([String: Double].self, from: savedCategoryData) {
                categorySums = savedCategories
        }
    }
    
    private func saveCategorySums() {
        if let encodedCategorySums = try? JSONEncoder().encode(categorySums) {
            UserDefaults.standard.set(encodedCategorySums, forKey: "CategorySums")
        }
    }
    
    private func loadCategoryLimits() {
        if let savedCategoryLimitData = UserDefaults.standard.data(forKey: "CategoryLimits"),
           let savedCategoryLimits = try? JSONDecoder().decode([String: Double].self, from: savedCategoryLimitData) {
            categoryLimits = savedCategoryLimits
        }
    }
    
    private func saveCategoryLimits() {
        if let encodedCategoryLimits = try? JSONEncoder().encode(categoryLimits) {
            UserDefaults.standard.set(encodedCategoryLimits, forKey: "CategoryLimits")
        }
    }
    
    func getCategoryBars(moneyManager: MoneyManager, category: String, months: Int, month: Int, year: Int) -> [CategoryBar] {
        var categoryBars: [CategoryBar] = []
        
        var selectedMonth = month
        var selectedYear = year
        
        for _ in 1...months {
            let filteredSum = getSelectedMonthCategorySum(moneyManager: moneyManager, category: category, month: selectedMonth, year: selectedYear)
            let maxLimit = categoryLimits[category]
            
            categoryBars.append(CategoryBar(maxLimit: maxLimit ?? 0, currentLimit: filteredSum, category: category, month: selectedMonth))
            
            if selectedMonth != 1 {
                selectedMonth -= 1
            } else {
                selectedMonth = 12
                selectedYear -= 1
            }
        }
        return categoryBars
    }
    
    func getAverage(categoryBars: [CategoryBar]) -> Double {
        var average = 0.0
        
        for bar in categoryBars {
            average += bar.currentLimit
        }
        average = average / Double(categoryBars.count)
        
        return average
    }
    
    func getYAxis(categoryBars: [CategoryBar]) -> Int {
        var maxValue = 0.0
        
        for bar in categoryBars {
            if bar.currentLimit > maxValue {
                maxValue = bar.currentLimit
            } else if bar.maxLimit > maxValue {
                maxValue = bar.maxLimit
            }
        }
        let maxValueInt = Int(maxValue * 1.1)
        return maxValueInt
    }
    
    func getLimitPercentage(category: String, categoryBar: [CategoryBar]) -> Int {
        let average = getAverage(categoryBars: categoryBar)
        let limit = categoryLimits[category] ?? 0
        
        if average > limit {
            let percentage = average / limit - 1
            return Int(percentage * 100)
        } else {
            let percentage = (average / limit - 1) * -1
            return Int(percentage * 100)
        }
    }
    
//    func getLimitMonths(moneyManager: MoneyManager, category: String, months: Int) -> [CategoryBar] {
//        var currentMonth = Calendar.current.component(.month, from: Date())
//        var currentYear = Calendar.current.component(.year, from: Date())
//        
//        var filteredLimits: [CategoryBar] = []
//        
//        for _ in 1...months {
//            let categoryTransactions = moneyManager.transactions.filter { transaction in
//                let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
//                return transactionComponents.month == currentMonth && transactionComponents.year == currentYear
//            }
//        }
//        return filteredLimits
//    }
    
    func limitIsExceeded(maxLimit: Double, currentLimit: Double) -> Bool {
        if maxLimit - currentLimit < 0 {
            return true
        } else {
            return false
        }
    }
    
}

struct Category {
    let category: String
    let expenses: [Transaction]
}

struct CategoryBar: Identifiable {
    let id = UUID()
    let maxLimit: Double
    let currentLimit: Double
    let category: String
    let month: Int
}

extension CategoryBar {
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM" // Customize the date format as needed#
        var component = DateComponents()
        component.month = month
        
        let date = Calendar.current.date(from: component)
        return dateFormatter.string(from: date!)
    }
}
