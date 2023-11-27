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
    
    init() {
        loadDebts()
    }
    
    func addTotalDebts(amount: Double) {
        totalDebts += amount
    }
    func removeTotalDebts(amount: Double) {
        totalDebts -= amount
    }
    
    func addDebitor(name: String) {
        let newDebitor = Debitor(name: name)
        if !debitors.contains(where: { $0.name == name }) {
            debitors.append(newDebitor)
        }
    }
    
    func addDebt(name: String, transaction: Transaction) {
        if let index = debitors.firstIndex(where: { $0.name == name }) {
            debitors[index].debts.append(transaction)
            debitors[index].debtAmount += transaction.amount
        }
        addTotalDebts(amount: transaction.amount)
        saveDebts()
    }
    
    func debtPaid(_ transaction: Transaction, from debitor: Debitor, _ moneyManager: MoneyManager){
        if let debitorIndex = debitors.firstIndex(of: debitor) {
            if let transactionIndex = debitor.debts.firstIndex(where: { $0.id == transaction.id }) {
                print("Transaction Index: \(transactionIndex)")
                debitors[debitorIndex].debts.remove(at: transactionIndex)
                print("Debts of selected Debitor: \(debitors[debitorIndex].debts)")
                removeTotalDebts(amount: transaction.amount)
                debitors[debitorIndex].debtAmount -= transaction.amount
                
                moneyManager.addTransaction(transaction)
                
            }

        }
        saveDebts()
        
    }
    func toggleDebitorExpansion(_ debitor: Debitor) {
        if let index = debitors.firstIndex(of: debitor) {
            debitors[index].isExpanded.toggle()
        }
    }
    
    
    private func loadDebts() {
        if let savedDebtData = UserDefaults.standard.data(forKey: "transactions"),
           let savedDebts = try? JSONDecoder().decode([Debitor].self, from: savedDebtData) {
            debitors = savedDebts
        }
    }
    
    private func saveDebts() {
        if let encodedDebts = try? JSONEncoder().encode(debitors) {
            UserDefaults.standard.set(encodedDebts, forKey: "Debts")
        }
    }

}

struct Debitor: Hashable, Identifiable, Codable {
    let id = UUID()
    let name: String
    var debtAmount: Double = 0
    var debts: [Transaction] = []
    var isExpanded: Bool = false
}
