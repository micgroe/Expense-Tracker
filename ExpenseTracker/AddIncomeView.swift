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
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    @ObservedObject var incomeManager: IncomeManager
    
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
                DatePicker("Date of Income", selection: $date, displayedComponents: .date)
            }
            
        }.navigationTitle("Add Income")
        .navigationBarItems(
            leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Add") {
                if let addAmount = Double(convertCommaToPeriod(amount)) {
                    incomeManager.addIncome(income: Income(amount: addAmount, date: date))
                }
                presentationMode.wrappedValue.dismiss()
            }
        )}
    }
struct AddIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        AddIncomeView(moneyManager: MoneyManager(), dateManager: DateManager(), incomeManager: IncomeManager())
    }
}
