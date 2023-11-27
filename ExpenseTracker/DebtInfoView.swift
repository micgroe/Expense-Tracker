//
//  DebtInfoView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 15.11.23.
//

import SwiftUI

struct DebtInfoView: View {
    @ObservedObject var debtManager: DebtManager
    @ObservedObject var moneyManager: MoneyManager
    
    @State private var testDebitors: [Debitor] = [Debitor(name: "Davis", debtAmount: 50, debts: [Transaction(amount: 20, date: Date(), category: "Car", description: "Test 1", icon: nil, type: "Debt"), Transaction(amount: 30, date: Date(), category: "Grocery", description: "Test 2", icon: nil, type: "Debt")]), Debitor(name: "Simon", debtAmount: 30, debts: [])]
    
    var body: some View {
        VStack {
            HStack {
                Text("Current Debts")
                    .font(.system(size: 35, weight: .bold))
                    .padding(.leading, 25)
                    .padding(.top, 40)
                Spacer()
            }
            if debtManager.debitors.isEmpty {
                Text("All your debts are paid!")
                    .foregroundColor(Color.gray)
                    .padding(.top, 50)
            }
            ForEach(debtManager.debitors, id: \.id) { debitor in
                //        ForEach(testDebitors, id: \.id) { debitor in
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(debitor.name).padding(.leading)
                                Spacer()
                                Text(String(format: "%.2f EUR", debitor.debtAmount))
                                Image(systemName: debitor.isExpanded ? "chevron.down" : "chevron.right")
                                    .padding(.horizontal)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    debtManager.toggleDebitorExpansion(debitor)
                                }
                            }
                            if debitor.isExpanded {
                                ForEach(debitor.debts, id: \.id) { transaction in
                                    VStack {
                                        if transaction == debitor.debts[0] {
                                            Divider()
                                        }
                                        HStack {
                                            Text(transaction.description)
                                                .padding(.leading, 30)
                                            Spacer()
                                            Text(String(format: "%.2f EUR", transaction.amount))
                                            Button(action: {
                                                debtManager.debtPaid(transaction, from: debitor, moneyManager)
                                            }, label: {
                                                Image(systemName: "creditcard.circle")
                                            }).padding(.horizontal)
                                        }
                                        .padding(.bottom, 5)
                                        if transaction != debitor.debts.last {
                                            Divider()
                                                .padding(.leading, 30)
                                        }
                                    }
                                }
                            }
                        }.padding(.leading, 5)
                        .padding(.vertical, 10)
                    }.background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                    }
                    Divider()
                }.padding(.horizontal)
            }
            Spacer()
        }
    }
}

struct DebtItemView: View {
    let transaction: Transaction
    let onDebtPaid: () -> Void

    var body: some View {
        HStack {
            Text(transaction.description)
            Spacer()
            Text(String(format: "%.2f EUR", transaction.amount))
                .padding(.trailing, 20)
            Button(action: {
                onDebtPaid()
            }, label: {
                Image(systemName: "creditcard.circle")
            })
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    DebtInfoView(debtManager: DebtManager(), moneyManager: MoneyManager())
}
