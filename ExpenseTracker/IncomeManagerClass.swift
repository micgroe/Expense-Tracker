//
//  IncomeManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 29.11.23.
//

import Foundation

class IncomeManager: ObservableObject {
    @Published var allIncomes: [Income] = []
    @Published var totalCurrentIncomes: Double = 0
    
    init() {
        loadIncomes()
    }
    
    func addTotalIncome(amount: Double) {
        totalCurrentIncomes += amount
    }
    
    func addIncome(income: Income) {
        allIncomes.append(income)
        addTotalIncome(amount: income.amount)
        saveIncomes()
    }
    
    func getCurrentMonthSum(dateManager: DateManager) -> Double {
        let currentIncomes = allIncomes.filter { income in
            let incomeComponents = Calendar.current.dateComponents([.year, .month], from: income.date)
            return incomeComponents.year == dateManager.currentYear && incomeComponents.month == dateManager.currentMonth
        }
        let currentSum = currentIncomes.reduce(0) { $0 + $1.amount }
        return currentSum
    }
    
    func getAggregatedMonths(months: Int, dateManager: DateManager) -> [Bar] {
        var aggregatedIncomes: [Int: Double] = [:]
        let calendar = Calendar.current
        var currentMonth = dateManager.currentMonth
        
        for _ in 1...months {
            let currentIncomes = allIncomes.filter { income in
                let componentMonth = calendar.component(.month, from: income.date)
                return componentMonth == currentMonth
            }
            for income in currentIncomes {
                let month = calendar.component(.month, from: income.date)
                aggregatedIncomes[month, default: 0] += income.amount
            }
            currentMonth -= 1
        }
        
        var result = aggregatedIncomes.map { (day, totalAmount) in
            return Bar(day: day, expense: totalAmount)
        }
        
        result = result.sorted { $0.day < $1.day }
        return result
    }
    
    func getAggregatedSum(aggregatedIncomes: [Bar]) -> Double {
        var aggregatedSum = 0.0
        for income in aggregatedIncomes {
            aggregatedSum += income.expense
        }
        return aggregatedSum
    }
    
    func calcAverageSavings(income: Double, expense: Double) -> Int {
        let saved = income - expense
        let savedPercent = Int(saved / income * 100)
        return savedPercent
    }
    
    private func loadIncomes() {
        if let savedIncomeData = UserDefaults.standard.data(forKey: "Incomes"),
           let savedIncomes = try? JSONDecoder().decode([Income].self, from: savedIncomeData) {
            allIncomes = savedIncomes
            for income in allIncomes {
                totalCurrentIncomes += income.amount
            }
        }
    }
    
    private func saveIncomes() {
        if let encodedIncomes = try? JSONEncoder().encode(allIncomes) {
            UserDefaults.standard.set(encodedIncomes, forKey: "Incomes")
        }
    }
}



struct Income: Hashable, Identifiable, Codable {
    let id = UUID()
    let amount: Double
    let date: Date
}
