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
                            moneyManager.addIncome(Income(amount: addAmount, date: date, description: description))
                            moneyManager.updateFilteredIncome(
                                selectedMonth: dateManager.currentMonth,
                                selectedYear: dateManager.currentYear
                            )
                            moneyManager.updateSelectedIncomeMonthBalance(
                                income: moneyManager.filteredIncome
                            )
                            amount = ""
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            moneyManager.addCredit(Income(amount: addAmount, date: date, description: description))
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
