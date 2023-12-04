//
//  MoneyManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 11.09.23.
//

import Foundation
import Charts

class MoneyManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var monthlyTransactions: [Transaction] = []

    @Published var expenses: [Transaction] = []
    @Published var monthlyExpenses: [Transaction] = []
    @Published var monthlyExpenseSum: Double = 0.0
    
    @Published var filteredCategoryBalances: [String: Double] = [:]
    
    @Published var groupedExpenses: [Int: Double] = [:]
    @Published var groupedBars: [Bar] = []
    @Published var comparisonExpenses: [Int: Double] = [:]
    @Published var sixMonthGroupedBars: [Bar] = []
    
    @Published var incomes: [Transaction] = []
    @Published var monthlyIncome: [Transaction] = []
    @Published var monthlyIncomeSum: Double = 0.0
    
    @Published var credits: [Transaction] = []
    @Published var creditAmount: Double = 0.0
    
    @Published var debts: [Transaction] = []
    @Published var debtAmount: Double = 0.0
    
    @Published var categoryTotals: [CategoryTotal] = []
    @Published var totalAmount: Double = 0.0
    
    @Published var filteredSixMonths: [Transaction] = []
    
    init() {
        // Load transactions from UserDefaults when initializing the manager
        loadAllTransactions()
    }
    
    func addTransaction(_ transaction: Transaction, categoryManager: CategoryManager) {
        transactions.append(transaction)
        categoryManager.addCategorySum(name: transaction.category!, amount: transaction.amount) //TODO: force unwrap transaction.category should be able to be removed later
        saveAllTransactions()
    }
    
    func removeTransaction(at Index: Int) {
        transactions.remove(at: Index)
        saveAllTransactions()
    }
    func getCurrentMonthSum(dateManager: DateManager) -> Double {
        let currentTransactions = transactions.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return transactionComponents.year == dateManager.currentYear && transactionComponents.month == dateManager.currentMonth
        }
        let currentSum = currentTransactions.reduce(0) { $0 + $1.amount }
        return currentSum
    }
    
    func getSelectedMonthSum(dateManager: DateManager) -> Double {
        let currentTransactions = transactions.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return transactionComponents.year == dateManager.selectedYear && transactionComponents.month == dateManager.selectedMonth
        }
        let currentSum = currentTransactions.reduce(0) { $0 + $1.amount }
        return currentSum
    }
    
    func getCurrentMonthExpenses(dateManager: DateManager) -> [Transaction] {
        let currentMonthExpenses = transactions.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return transactionComponents.year == dateManager.selectedYear && transactionComponents.month == dateManager.selectedMonth
        }
        return currentMonthExpenses
    }
    
    func getAggregatedDays(dateManager: DateManager) -> [Bar] {
        var aggregatedTransactions: [Int: Double] = [:]

        let calendar = Calendar.current

        for transaction in getCurrentMonthExpenses(dateManager: dateManager) {
            let day = calendar.component(.day, from: transaction.date)
            aggregatedTransactions[day, default: 0] += transaction.amount
        }
        
        var result = aggregatedTransactions.map { (day, totalAmount) in
            return Bar(day: day, expense: totalAmount)
        }
        
        result = result.sorted { $0.day < $1.day }
        return result
    }
    
    func getCurrentDayExpenses(dateManager: DateManager, day: Int) -> [Transaction] {
        let currentDayExpenses = getCurrentMonthExpenses(dateManager: dateManager).filter { transaction in
            let transactionDay = Calendar.current.component(.day, from: transaction.date)
            return transactionDay == day
        }
        return currentDayExpenses
    }
    
    func getMaxExpense(dateManager: DateManager) -> Double? {
        guard let maxTransaction = getAggregatedDays(dateManager: dateManager).max(by: { $0.expense < $1.expense }) else {
            return nil
        }
        return maxTransaction.expense
    }
    
    func getAggregatedMonths(months: Int, dateManager: DateManager) -> [Bar] {
        var aggregatedTransactions: [Int: Double] = [:]
        let calendar = Calendar.current
        var currentMonth = dateManager.currentMonth
        
        for _ in 1...months {
            let currentExpenses = transactions.filter { transaction in
                let componentMonth = calendar.component(.month, from: transaction.date)
                return componentMonth == currentMonth
            }
            for transaction in currentExpenses {
                let month = calendar.component(.month, from: transaction.date)
                aggregatedTransactions[month, default: 0] += transaction.amount
            }
            currentMonth -= 1
        }
        
        var result = aggregatedTransactions.map { (day, totalAmount) in
            return Bar(day: day, expense: totalAmount)
        }
        
        result = result.sorted { $0.day < $1.day }
        return result
    }
    
//    Old functions
    func updateMonthlyTransactions(selectedMonth: Int, selectedYear: Int, transactionType: String) {
        switch transactionType {
        case "Expense":
            monthlyExpenses = transactions.filter { transaction in
                let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
                return transactionComponents.year == selectedYear && transactionComponents.month == selectedMonth && transaction.type == transactionType
            }
        case "Income":
            monthlyIncome = transactions.filter { transaction in
                let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
                return transactionComponents.year == selectedYear && transactionComponents.month == selectedMonth && transaction.type == transactionType
            }
        default:
            monthlyTransactions = transactions.filter { transaction in
                let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
                return transactionComponents.year == selectedYear && transactionComponents.month == selectedMonth
            }
        }

    }
    
    func getFilteredSixMonthExpenses(_ month: Int, _ year: Int) -> [Transaction] {
        let month = month - 6
        let year = year
        var filteredExpenses: [Transaction] = []
        filteredExpenses = transactions.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return transactionComponents.year == year && transactionComponents.month! > month
        }
        return filteredExpenses
    }
    
    func updateFilteredSixMonthExpenses(_ month: Int, _ year: Int) {
        let month = month - 6
        let year = year
        var filteredExpenses: [Transaction] = []
        filteredExpenses = transactions.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return transactionComponents.year == year && transactionComponents.month! > month
        }
        filteredSixMonths = filteredExpenses
    }
    
    func updateMonthlyTransactionSum(monthlyTransactions: [Transaction], transactionType: String) {
        switch transactionType {
        case "Expense":
            monthlyExpenseSum = 0
            for transaction in monthlyTransactions {
                monthlyExpenseSum += transaction.amount
        }
        case "Income":
            monthlyIncomeSum = 0
            for transaction in monthlyTransactions {
                monthlyIncomeSum += transaction.amount
            }
        default:
            print("RIP")
        }
    }
    
    func getMonthlyExpenses(_ month: Int, _ year: Int) -> [Transaction] {
        var monthlyExpenses: [Transaction] = []
        monthlyExpenses = transactions.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return transactionComponents.year == year && transactionComponents.month == month
        }
        return monthlyExpenses
    }
    
    func getSixMonthExpenses(_ month: Int, _ year: Int, expense: [Transaction]) -> [[Transaction]] {
        var sixMonthExpenses: [[Transaction]] = []
        
        for i in 0...5 {
            let currentMonth = month - i
            let currentYear = month <= 0 ? year - 1 : year

            let components = DateComponents(year: currentYear, month: currentMonth)
            let date = Calendar.current.date(from: components)!
            
            var monthlyExpense = getMonthlyExpenses(currentMonth, currentYear)
            
            if monthlyExpense.isEmpty {
                monthlyExpense.append(Transaction(amount: 0, date: date, category: "Car", description: "Nothing", icon: nil, type: "Expense"))
            }

            sixMonthExpenses.append(monthlyExpense)
        }
        return sixMonthExpenses
    }

    func updateGroupedSixMonthBars(sixMonthExpenses: [[Transaction]]) {
        sixMonthGroupedBars = []
        var groupedSixMonths: [Int: Double] = [:]
        for transactionsInMonth in sixMonthExpenses {
            guard let firstTransaction = transactionsInMonth.first else {
                continue // Skip empty months
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM" // Format to represent the month and year
            
            let monthInt = Calendar.current.component(.month, from: firstTransaction.date)
            
            let totalAmount = transactionsInMonth.reduce(0.0) { $0 + $1.amount }
            
            groupedSixMonths[monthInt] = totalAmount
        }
        
        for expense in groupedSixMonths {
            sixMonthGroupedBars.append(Bar(day: expense.key, expense: expense.value))
        }
    }
    
    func getMonthlyExpenseSum(_ month: Int, _ year: Int) -> Double {
        let monthlyTransactions = transactions.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return transactionComponents.year == year && transactionComponents.month == month
        }
        let monthlyExpense = monthlyTransactions.reduce(0.0) { $0 + $1.amount }
        return monthlyExpense
    }

    
    func updateCategoryBalancesForMonth() {
        for key in filteredCategoryBalances.keys {
            filteredCategoryBalances[key] = 0.0
        }
        
        for transaction in monthlyTransactions {
            filteredCategoryBalances[transaction.category!, default: 0.0] += transaction.amount
        }
        
        // Sort the category balances by amount (descending order)
        let sortedBalances = filteredCategoryBalances.sorted { $0.value > $1.value }
        filteredCategoryBalances = Dictionary(uniqueKeysWithValues: sortedBalances)
    }
    
    func getMaxSixMonthAmount(bars: [Bar]) -> Double {
        var maxAmount = 0.0
        for bar in bars {
            if bar.expense > maxAmount {
                maxAmount = bar.expense
            }
        }
        return maxAmount
    }
    
    func calculateGroupedExpenses(for month: Int, year: Int, expenses: [Transaction]) -> [String: Double] {
        var groupedExpenses: [String: Double] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        for expense in expenses {
            let dateString = dateFormatter.string(from: expense.date)
            
            if groupedExpenses[dateString] != nil {
                groupedExpenses[dateString]! += expense.amount
            } else {
                groupedExpenses[dateString] = expense.amount
            }
        }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        if let firstDayOfMonth = Calendar.current.date(from: components) {
            // Calculate the range of days for the current month
            if let range = Calendar.current.range(of: .day, in: .month, for: firstDayOfMonth) {
                
                // Iterate through the range of days and add them to the dictionary with values set to 0
                for day in range {
                    components.day = day
                    if let date = Calendar.current.date(from: components) {
                        // Format the date as a string in yyyy-MM-dd format
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM"
                        let dateString = dateFormatter.string(from: date)
                        
                        if groupedExpenses[dateString] == nil {
                            groupedExpenses[dateString] = 0.0
                        }
                    }
                }
            }
        }
        return groupedExpenses
    }
    
    func updateGroupedExpenses(_ month: Int, _ year: Int) {
        groupedExpenses = [:]
        groupedBars = []
        var tempGroupedExpenses: [String: Double] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        
        for expense in monthlyExpenses {
            let dateString = dateFormatter.string(from: expense.date)
            
            if tempGroupedExpenses[dateString] != nil {
                tempGroupedExpenses[dateString]! += expense.amount
            } else {
                tempGroupedExpenses[dateString] = expense.amount
            }
        }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        if let firstDayOfMonth = Calendar.current.date(from: components) {
            // Calculate the range of days for the current month
            if let range = Calendar.current.range(of: .day, in: .month, for: firstDayOfMonth) {
                
                // Iterate through the range of days and add them to the dictionary with values set to 0
                for day in range {
                    components.day = day
                    if let date = Calendar.current.date(from: components) {
                        // Format the date as a string in yyyy-MM-dd format
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd"
                        let dateString = dateFormatter.string(from: date)
                        
                        if tempGroupedExpenses[dateString] == nil {
                            tempGroupedExpenses[dateString] = 0.0
                        }
                    }
                }
            }
        }

        for (key, value) in tempGroupedExpenses {
            if let intKey = Int(key) {
                groupedExpenses[intKey] = value
            }
        }
        
        let sortedArray = groupedExpenses.sorted { $0.key < $1.key }
        
        for (key, value) in sortedArray {
            groupedExpenses[key] = value
        }
        
        for expense in groupedExpenses {
            groupedBars.append(Bar(day: expense.key, expense: expense.value))
        }
    }
    
    func getPercentageDifference(_ month: Int, _ year: Int) -> Double? {
        let thisMonth = getMonthlyExpenseSum(month, year)
        let lastMonth = getMonthlyExpenseSum(month-1, year)
        
        guard lastMonth != 0 else {
            return nil // Avoid division by zero
        }
        
        let percentageChange = (lastMonth - thisMonth) / lastMonth * 100
        return percentageChange
    }
    
    func updateDebts() {
        debts = []
        for debt in transactions {
            if debt.type == "Debt" {
                debts.append(debt)
            }
        }
    }
    
    func updateDebtAmount() {
        debtAmount = 0
        for debt in debts {
            debtAmount += debt.amount
        }
    }
    
    private func loadAllTransactions() {
        if let savedTransactionsData = UserDefaults.standard.data(forKey: "transactions"),
           let savedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactionsData) {
            transactions = savedTransactions
        }
    }
    
    private func saveAllTransactions() {
        if let encodedTransactions = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encodedTransactions, forKey: "transactions")
        }
    }
    
    func updateCredits() {
        credits = []
        for credit in transactions {
            if credit.type == "Credit" {
                credits.append(credit)
            }
        }
    }
    
    func updateCreditAmount() {
        creditAmount = 0
        for credit in credits {
            creditAmount += credit.amount
        }
    }
    
    func updateCategoryTotals(transactions: [Transaction]){
        var tempCategoryTotals: [CategoryTotal] = []
        
        for transaction in transactions {
            if let existingCategoryIndex = tempCategoryTotals.firstIndex(where: { $0.category == transaction.category }) {
                tempCategoryTotals[existingCategoryIndex].totalAmount += transaction.amount
            } else {
                tempCategoryTotals.append(CategoryTotal(category: transaction.category!, totalAmount: transaction.amount, icon: transaction.icon!))
            }
        }
        categoryTotals = tempCategoryTotals.sorted { $0.totalAmount > $1.totalAmount }
    }
    func updateTotalAmount(transactions: [Transaction]) {
        totalAmount = 0.0
        for expense in transactions {
            totalAmount += expense.amount
        }
    }
    
}

struct Transaction: Hashable, Identifiable, Codable, Equatable {
    let id = UUID()
    let amount: Double
    let date: Date
    let category: String?
    let description: String
    let icon: String?
    let type: String
}

struct CategoryTotal: Identifiable {
    let id = UUID()
    let category: String
    var totalAmount: Double
    let icon: String
}

extension Transaction {
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM" // Customize the date format as needed
        return dateFormatter.string(from: date)
    }
}
