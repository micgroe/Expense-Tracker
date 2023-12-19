//
//  MonthlyPaymentsView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 03.10.23.
//

import SwiftUI

struct MonthlyPaymentsView: View {
    @ObservedObject var monthlyPaymentManager: MonthlyPaymentManager
    @ObservedObject var dateManager: DateManager
    @ObservedObject var categoryManager: CategoryManager
    
    @State var isShowingAddSubscriptionView = false
    @State var selectedCategory: String? = nil
    @State var paymentAmount: String? = nil
    @State var paymentDescription: String? = nil
    
    let itemsPerRow = 4
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("current Payments")) {
                if !monthlyPaymentManager.monthlyPayments.isEmpty {
                    List {
                        ForEach(monthlyPaymentManager.monthlyPayments, id: \.id) { payment in
                            HStack {
                                Text(String(payment.description))
                                Spacer()
                                Text(String(format: "%.2f", payment.amount))
                            }
                        }.onDelete { indexSet in
                            let payments = indexSet.map { Array(monthlyPaymentManager.monthlyPayments)[$0] }
                            for payment in payments {
                                monthlyPaymentManager.removeMonthlyPayment(payment: payment)
                            }
                        }
                    }
                } else {
                    Text("No monthly payments added yet!")
                        .backgroundStyle(Color(.systemBackground))
                }
            }
            Section(header: Text("add monthly Payment")) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: itemsPerRow), spacing: 16) {
                    ForEach(categoryManager.categoryIcons.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                        VStack {
                            VStack {
                                Image(systemName: value)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                Text(key)
                                    .font(.system(size: 13))
                            }.frame(width: 55, height: 55)
                        }.frame(width: 75, height: 75)
                        .background(selectedCategory == key ? Color.blue.opacity(0.7) : Color.clear)
                        .onTapGesture {
                            selectedCategory = key
                        }.cornerRadius(5)
                    }
                }
                TextField("Enter description", text: Binding(
                    get: { paymentDescription ?? ""},
                    set: { paymentDescription = $0 }
                ))
                HStack {
                    TextField("Enter amount", text: Binding(
                         get: { paymentAmount ?? "" },
                         set: { paymentAmount = $0 }
                     ))
                        .keyboardType(.decimalPad)
                    Spacer()
                    Button("Add") {
                        if let category = selectedCategory, let amount = Double(paymentAmount!), let description = paymentDescription {
                            monthlyPaymentManager.addMonthlyPayment(amount: amount, category: category, description: description)
                            selectedCategory = nil
                            paymentAmount = nil
                        }
                    }.foregroundStyle(selectedCategory != nil && paymentAmount != nil && paymentDescription != nil ? Color.blue : Color.gray)
                }
                
            }
        }.navigationTitle("Monthly Payments")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
            })
    }
}

#Preview {
    MonthlyPaymentsView(monthlyPaymentManager: MonthlyPaymentManager(), dateManager: DateManager(), categoryManager: CategoryManager())
}
