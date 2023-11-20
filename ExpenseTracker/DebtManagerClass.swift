//
//  DebtManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 15.11.23.
//

import Foundation

class DebtManager: ObservableObject {
    @Published var totalDebts: Double = 0
    @Published var debitors: [Debitor] = []
    
    func addTotalDebts(amount: Double) {
        totalDebts += amount
    }
    
    func addDebitor(name: String) {
        if !debitors.contains(where: { $0.name == name }) {
            debitors.append(Debitor(name: name))
            
        }
    }
    
    func addDebt(name: String, transaction: Transaction) {
        if let index = debitors.firstIndex(where: { $0.name == name }) {
            debitors[index].debts.append(transaction)
            debitors[index].debtAmount += transaction.amount
        }
        addTotalDebts(amount: transaction.amount)
    }
}

struct Debitor: Hashable, Identifiable, Codable {
    let id = UUID()
    let name: String
    var debtAmount: Double = 0
    var debts: [Transaction] = []
    var isExpanded: Bool = false
}
