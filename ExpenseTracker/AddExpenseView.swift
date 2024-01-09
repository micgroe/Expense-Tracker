//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 10.09.23.
//

import SwiftUI
import RealmSwift

struct AddExpenseView: View {
//    @ObservedResults(Expense.self) var expenses
    
    private func subscribe() {
        let subscriptions = realm.subscriptions
        if subscriptions.first(named: "Expenses") == nil {
            subscriptions.update {
                subscriptions.append(QuerySubscription<Expense>(name: "Expenses"))
            }
        }
    }
    
//    @ObservedObject var testManager: TestManager
    
    private func unsubscribe() {
        let subscriptions = realm.subscriptions
        subscriptions.remove(named: "Expenses")
    }
    
    private func convertCommaToPeriod(_ input: String) -> String {
        return input.replacingOccurrences(of: ",", with: ".")
    }
    
    var categories = [
        "House": "house.fill",
        "Travel": "airplane",
        "Grocery": "cart.fill",
        "Gaming": "gamecontroller.fill",
        "Car": "car.fill",
        "Restaurant": "fork.knife",
        "Sports": "figure.run",
        "Alcohol": "wineglass"
    ]
    let itemsPerRow = 4
    
//    @ObservedObject var testManager: TestManager
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    @ObservedObject var categoryManager: CategoryManager
    
    var selectedOption: String?
    
    let username: String
    
    @State private var amount = ""
    @State private var description = ""
    @State private var date = Date()
    
    @State private var selectedItem: String? = nil
    @State private var selectedItemIcon: String? = nil
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.realm) var realm
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Enter Details")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $description)
                    DatePicker("Date of debt", selection: $date, displayedComponents: .date)
                }
                Section(header: Text("Select Category")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: itemsPerRow), spacing: 16)  {
                        ForEach(categories.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                            VStack {
                                VStack {
                                    Image(systemName: value)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    Text(key)
                                        .font(.system(size: 13))
                                }.frame(width: 55, height: 55)
                            }.frame(width: 75, height: 75)
                                .background(selectedItem == key ? Color.blue.opacity(0.7) : Color.clear)
                                .onTapGesture {
                                    selectedItem = key
                                    selectedItemIcon = value
                            }.cornerRadius(5)
                        }
                    }
                }
            }.frame(height: 430)
            if let category = selectedItem {
                    let maxLimit = categoryManager.categoryLimits[category] ?? 0
                    let currentLimit = categoryManager.getCurrentMonthCategorySum(moneyManager: moneyManager, category: category)
                    let currentExpense = Double(amount) ?? 0
                    let remainingLimit = categoryManager.getRemainingLimit(maxLimit: maxLimit, currentLimit: currentLimit)

                if !categoryManager.categoryLimits.keys.contains(category) {
                    Text("No limit added for this category")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                } else {
                    if remainingLimit - currentExpense > 0 {
                        Text("Remaining limit for this category:")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Text(String(format: "%.2f EUR", remainingLimit))
                            .font(.system(size: 23))
                            .foregroundColor(categoryManager.getLineColor(currentLimit: remainingLimit, category: category))
                    } else if remainingLimit <= 0 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("You have already reached your limit this month!")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                    } else {
                        VStack {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                Text("This expense will exceed your limit!")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Remaining limit:")
                                    .foregroundColor(.gray)
                                Text(String(format: "%.2f EUR", remainingLimit))
                                    .foregroundColor(.red)
                                    .font(.system(size: 20))
                            }.padding(.top, 1)
                        }
                    }
                }
            }
            Spacer()
        }.onAppear {
//            subscribe()
        }.onDisappear() {
//            unsubscribe()
        }
        .navigationTitle("Add \(selectedOption ?? "")")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    if let addAmount = Double(convertCommaToPeriod(amount)), let addCategory = selectedItem {
                        moneyManager.addTransaction(Transaction(
                                                    amount: addAmount,
                                                    date: date,
                                                    category: selectedItem ?? "Other",
                                                    description: description,
                                                    icon: selectedItemIcon ?? "Other",
                                                    type: selectedOption!), categoryManager: categoryManager)
//                        moneyManager.addExpenseDB(amount: addAmount, category: addCategory, descriptions: description)
//                        $expenses.append(Expense(amount: addAmount, date: Date(), category: addCategory, descriptions: description))
//                        testManager.addExpense(expense: Expense(userID: username, amount: addAmount, date: date, category: addCategory, descriptions: description))

                    amount = ""
                    presentationMode.wrappedValue.dismiss()
                }

                
            }.disabled(selectedItemIcon==nil))
    }
}
