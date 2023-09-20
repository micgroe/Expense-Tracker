//
//  MoneyManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 11.09.23.
//

import Foundation

class MoneyManager: ObservableObject {
    @Published var categoryBalances: [String: Double] = [:]
    @Published var transactions: [Expense] = []
    @Published var filteredTransactions: [Expense] = []
    @Published var filteredTransactionSum: Double = 0.0
    @Published var filteredCategoryBalances: [String: Double] = [:]
    
    @Published var incomes: [Income] = []
    @Published var filteredIncome: [Income] = []
    @Published var filteredIncomeSum: Double = 0.0
    
    @Published var credits: [Income] = []
    @Published var creditAmount: Double = 0.0
    
    @Published var debts: [Expense] = []
    @Published var debtAmount: Double = 0.0
    
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
        
        // Load transactions from UserDefaults when initializing the manager
        loadAllTransactions()
        loadDebts()
        loadIncome()
        loadCredits()
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
    
    func addTransaction(_ transaction: Expense) {
        transactions.append(transaction)
        saveAllTransactions()
    }
    
    func removeTransaction(at Index: Int) {
        transactions.remove(at: Index)
        saveAllTransactions()
    }
    
    func updateSelectedMonthBalance(transactions: [Expense]) {
        filteredTransactionSum = 0
        for transaction in transactions {
            filteredTransactionSum += transaction.amount
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
    
    func addDebt(_ debt: Expense) {
        debts.append(debt)
        updateDebtAmount()
        saveDebts()
    }
    
    func deleteDebt(_ debt: Expense, _ selectedMonth: Int, _ selectedYear: Int) {
        if let index = debts.firstIndex(of: debt) {
            debts.remove(at: index)
        }
        updateDebtAmount()
        addTransaction(debt)
        updateFilteredTransactions(selectedMonth: selectedMonth, selectedYear: selectedYear)
        updateSelectedMonthBalance(transactions: filteredTransactions)
        updateCategoryBalancesForMonth()
        saveDebts()
    }
    
    func updateDebtAmount() {
        debtAmount = 0
        for debt in debts {
            debtAmount += debt.amount
        }
    }
    
    private func loadAllTransactions() {
        if let savedTransactionsData = UserDefaults.standard.data(forKey: "transactions"),
           let savedTransactions = try? JSONDecoder().decode([Expense].self, from: savedTransactionsData) {
            transactions = savedTransactions
        }
    }
    
    private func saveAllTransactions() {
        if let encodedTransactions = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encodedTransactions, forKey: "transactions")
        }
    }
    
    private func loadDebts() {
        if let savedDebtData = UserDefaults.standard.data(forKey: "debts"),
           let savedDebts = try? JSONDecoder().decode([Expense].self, from: savedDebtData) {
            debts = savedDebts
        }
    }
    
    private func saveDebts() {
        if let encodedDebts = try? JSONEncoder().encode(debts) {
            UserDefaults.standard.set(encodedDebts, forKey: "debts")
        }
    }
    
    func addIncome(_ income: Income) {
        incomes.append(income)
        saveIncome()
    }
    
    func removeIncome(at Index: Int) {
        incomes.remove(at: Index)
        saveIncome()
    }
    
    func updateFilteredIncome(selectedMonth: Int, selectedYear: Int) {
        filteredIncome = incomes.filter { income in
            let incomeComponents = Calendar.current.dateComponents([.year, .month], from: income.date)
            return incomeComponents.year == selectedYear && incomeComponents.month == selectedMonth
        }
    }
    
    func updateSelectedIncomeMonthBalance(income: [Income]) {
        filteredIncomeSum = 0
        for income in filteredIncome {
            filteredIncomeSum += income.amount
        }
    }
    
    private func loadIncome() {
        if let savedIncomeData = UserDefaults.standard.data(forKey: "income"),
           let savedIncome = try? JSONDecoder().decode([Income].self, from: savedIncomeData) {
            incomes = savedIncome
        }
    }
    
    private func saveIncome() {
        if let encodedIncome = try? JSONEncoder().encode(incomes) {
            UserDefaults.standard.set(encodedIncome, forKey: "income")
        }
    }
    
    func addCredit(_ credit: Income) {
        credits.append(credit)
        updateCreditAmount()
        saveCredits()
    }
    
    func deleteCredit(_ credit: Income, _ selectedMonth: Int, _ selectedYear: Int) {
        if let index = credits.firstIndex(of: credit) {
            credits.remove(at: index)
        }
        updateCreditAmount()
        saveCredits()
    }
    
    func updateCreditAmount() {
        creditAmount = 0
        for credit in credits {
            creditAmount += credit.amount
        }
    }
    
    private func loadCredits() {
        if let savedCreditsData = UserDefaults.standard.data(forKey: "credit"),
           let savedCredits = try? JSONDecoder().decode([Income].self, from: savedCreditsData) {
            credits = savedCredits
        }
    }
    
    private func saveCredits() {
        if let encodedCredits = try? JSONEncoder().encode(credits) {
            UserDefaults.standard.set(encodedCredits, forKey: "credit")
        }
    }
}

struct Expense: Hashable, Identifiable, Codable {
    let id = UUID()
    let amount: Double
    let date: Date
    let category: String
    let description: String
    let icon: String
}

struct Income: Hashable, Identifiable, Codable {
    let id = UUID()
    let amount: Double
    let date: Date
    let description: String
}
