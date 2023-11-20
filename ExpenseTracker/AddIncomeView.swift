//
//  AddIncomeView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 20.09.23.
//

import SwiftUI

struct AddIncomeView: View {
        private func convertCommaToPeriod(_ input: String) -> String {
            return input.replacingOccurrences(of: ",", with: ".")
        }
        
        let categories = [
            "House": "house.fill",
            "Travel": "airplane",
            "Grocery": "cart.fill",
            "Gaming": "gamecontroller.fill",
            "Car": "car.fill",
            "Restaurant": "wineglass",
            "Sports": "figure.run"
        ]
        let itemsPerRow = 4
        
        @ObservedObject var moneyManager: MoneyManager
        @ObservedObject var dateManager: DateManager
        
        var selectedOption: String?
        
        @State private var amount = ""
        @State private var description = ""
        @State private var date = Date()
        
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            ZStack {
                Form {
                    TextField("Enter Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $description)
                    if let option = selectedOption {
                        DatePicker("Date of \(option)", selection: $date, displayedComponents: .date)
                    }
                }
                
            }.navigationTitle("Add \(selectedOption ?? "")")
            .navigationBarItems(
                leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    if let addAmount = Double(convertCommaToPeriod(amount)) {
                        if selectedOption == "Income" {
                            moneyManager.addTransaction(Transaction(amount: addAmount, date: date, category: nil, description: description, icon: nil, type: selectedOption!))
                            moneyManager.updateMonthlyTransactions(selectedMonth: dateManager.currentMonth,
                                                                   selectedYear: dateManager.currentYear, transactionType: selectedOption!
                            )
                            moneyManager.updateMonthlyTransactionSum(monthlyTransactions: moneyManager.monthlyIncome, transactionType: selectedOption!
                            )
                            amount = ""
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            moneyManager.addTransaction(Transaction(amount: addAmount, date: date, category: nil, description: description, icon: nil, type: selectedOption!))
                            moneyManager.updateCredits()
                            moneyManager.updateCreditAmount()
                            amount = ""
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        )}
    }
struct AddIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        AddIncomeView(moneyManager: MoneyManager(), dateManager: DateManager(), selectedOption: "Income")
    }
}
