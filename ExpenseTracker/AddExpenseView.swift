//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 10.09.23.
//

import SwiftUI

struct AddExpenseView: View {
    
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
    
    @State private var selectedItem: String? = nil
    @State private var selectedItemIcon: String? = nil
    
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
                Section(header: Text("Category")) {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: itemsPerRow), spacing: 16)  {
                                ForEach(categories.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                                VStack {
                                    Image(systemName: value)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    Text(key)
                                        .font(.system(size: 13))
                                }.frame(width: 55, height: 55)
                                .background(selectedItem == key ? Color.blue.opacity(0.7) : Color.clear)
                                .onTapGesture {
                                    selectedItem = key
                                    selectedItemIcon = value
                                }.cornerRadius(5)
                                .padding(5)
                            }
                        }
                    }
                }
            }
            
        }.navigationTitle("Add \(selectedOption ?? "")")
        .navigationBarItems(
            leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Add") {
                if let addAmount = Double(convertCommaToPeriod(amount)) {
                    if selectedOption == "Expense" {
                        moneyManager.addTransaction(Expense(
                                                        amount: addAmount,
                                                        date: date,
                                                        category: selectedItem ?? "Other",
                                                        description: description,
                                                        icon: selectedItemIcon ?? "Other"))
                        moneyManager.addMoney(addAmount, to: selectedItem ?? "Other")
                        moneyManager.updateFilteredTransactions(
                            selectedMonth: dateManager.currentMonth,
                            selectedYear: dateManager.currentYear
                        )
                        moneyManager.updateCategoryBalancesForMonth()
                        moneyManager.updateSelectedMonthBalance(
                            transactions: moneyManager.filteredTransactions
                        )
                    } else {
                        moneyManager.addDebt(Expense(
                            amount: addAmount,
                            date: date,
                            category: selectedItem ?? "Other",
                            description: description,
                            icon: selectedItemIcon ?? "Other"))
                        
                        moneyManager.updateDebtAmount()
                    }

                    amount = ""
                    presentationMode.wrappedValue.dismiss()
                }

                
            }.disabled(selectedItemIcon==nil))
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(moneyManager: MoneyManager(), dateManager: DateManager(), selectedOption: "Debt")
    }
}
