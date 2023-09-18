//
//  MoneyManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 11.09.23.
//

import Foundation

class MoneyManager: ObservableObject {
    @Published var categoryBalances: [String: Double] = [:]
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var filteredSum: Double = 0.0
    @Published var filteredCategoryBalances: [String: Double] = [:]
    
    @Published var debts: [Transaction] = []
    
    init() {
        // Initialize the dictionary with default categories and balances
        categoryBalances["Grocery"] = 0.0
        categoryBalances["House"] = 0.0
        categoryBalances["Travel"] = 0.0
        categoryBalances["Gaming"] = 0.0
        categoryBalances["Car"] = 0.0
        categoryBalances["Restaurant"] = 0.0
        categoryBalances["Sports"] = 0.0
        // Add more categories as needed
    }
    
    func addMoney(_ amount: Double, to category: String) {
        if var balance = categoryBalances[category] {
            balance += amount
            categoryBalances[category] = balance
        }
    }
    
    func removeMoney(_ amount: Double, to category: String) {
        if var balance = categoryBalances[category] {
            balance -= amount
            categoryBalances[category] = balance
        }
    }
    
    func updateFilteredTransactions(selectedMonth: Int, selectedYear: Int) {
        filteredTransactions = transactions.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return transactionComponents.year == selectedYear && transactionComponents.month == selectedMonth
        }
    }
    
    func getCategoryBalance(_ category: String) -> Double {
        return categoryBalances[category] ?? 0.0
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    func removeTransaction(at Index: Int) {
        transactions.remove(at: Index)
    }
    
    func updateSelectedMonthBalance(transactions: [Transaction]) {
        filteredSum = 0
        for transaction in transactions {
            filteredSum += transaction.amount
        }
    }
    
    func updateCategoryBalancesForMonth() {
        for key in filteredCategoryBalances.keys {
            filteredCategoryBalances[key] = 0.0
        }
        
        for transaction in filteredTransactions {
            filteredCategoryBalances[transaction.category, default: 0.0] += transaction.amount
        }
        
        // Sort the category balances by amount (descending order)
        let sortedBalances = filteredCategoryBalances.sorted { $0.value > $1.value }
        filteredCategoryBalances = Dictionary(uniqueKeysWithValues: sortedBalances)
    }
    
    func addDebt(_ debt: Transaction) {
        debts.append(debt)
    }
    
    func deleteDebt(_ debt: Transaction, _ selectedMonth: Int, _ selectedYear: Int) {
        if let index = debts.firstIndex(of: debt) {
            debts.remove(at: index)
        }
        addTransaction(debt)
        updateFilteredTransactions(selectedMonth: selectedMonth, selectedYear: selectedYear)
        updateSelectedMonthBalance(transactions: filteredTransactions)
        updateCategoryBalancesForMonth()
    }
}

struct Transaction: Hashable, Identifiable {
    let id = UUID()
    let amount: Double
    let date: Date
    let category: String
    let description: String
    let icon: String
}