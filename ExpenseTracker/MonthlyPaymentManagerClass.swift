//
//  MonthlyPaymentManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 02.12.23.
//

import Foundation

class MonthlyPaymentManager: ObservableObject {
    @Published var monthlyPayments: [MonthlyPayment] = []
    
    init() {
        loadMonthlyPayments()
    }
    
    func addMonthlyPayment(amount: Double, category: String, description: String) {
        monthlyPayments.append(MonthlyPayment(amount: amount, category: category, description: description))
        saveMonthlyPayments()
    }
    
    func removeMonthlyPayment(payment: MonthlyPayment) {
        if let index = monthlyPayments.firstIndex(of: payment) {
            monthlyPayments.remove(at: index)
        }
        saveMonthlyPayments()
    }
    
    func addTransaction(monthlyPayment: MonthlyPayment, moneyManager: MoneyManager, categoryManager: CategoryManager) {
        if monthlyPayment.isPaid == false {
            moneyManager.addTransaction(Transaction(amount: monthlyPayment.amount, date: Date(), category: monthlyPayment.category, description: monthlyPayment.description, icon: "", type: "Expense"), categoryManager: categoryManager)

            if let index = monthlyPayments.firstIndex(of: monthlyPayment) {
                monthlyPayments[index].isPaid = true
                monthlyPayments[index].paidDate = Date()
            }
        }
    }
    
    func newMonthHasBegun(monthlyPayment: MonthlyPayment, dateManager: DateManager) -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: monthlyPayment.paidDate)
        
        if dateManager.currentMonth != month {
            if let index = monthlyPayments.firstIndex(of: monthlyPayment) {
                monthlyPayments[index].isPaid = false
            }
            return true
        } else {
            return false
        }
    }
    
    private func loadMonthlyPayments() {
        if let savedMonthlyPaymentData = UserDefaults.standard.data(forKey: "monthlyPayments"),
           let savedMonthlyPayments = try? JSONDecoder().decode([MonthlyPayment].self, from: savedMonthlyPaymentData) {
            monthlyPayments = savedMonthlyPayments
        }
    }
    
    private func saveMonthlyPayments() {
        if let encodedMonthlyPayments = try? JSONEncoder().encode(monthlyPayments) {
            UserDefaults.standard.set(encodedMonthlyPayments, forKey: "monthlyPayments")
        }
    }
}

struct MonthlyPayment: Hashable, Identifiable, Codable {
    let id = UUID()
    var amount: Double
    var category: String
    var description: String
    var isPaid: Bool = true
    var paidDate: Date = Date()
}
