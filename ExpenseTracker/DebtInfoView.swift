//
//  DebtInfoView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 15.11.23.
//

import SwiftUI

struct DebtInfoView: View {
    @ObservedObject var debtManager: DebtManager
    
    @State private var testDebitors: [Debitor] = [Debitor(name: "Davis", debtAmount: 50, debts: [Transaction(amount: 20, date: Date(), category: "Car", description: "Test 1", icon: nil, type: "Debt"), Transaction(amount: 30, date: Date(), category: "Grocery", description: "Test 2", icon: nil, type: "Debt")])]
    
    var body: some View {
        List {
            ForEach($testDebitors, id: \.id) { $debitor in
                //change testDebitors with debtManager.debitors
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { debitor.isExpanded },
                        set: { newValue in
                            debitor.isExpanded = newValue
                        }
                    ),
                    content: {
                        VStack(alignment: .leading) {

                            if debitor.isExpanded {
                                ForEach(debitor.debts, id: \.self) { transaction in
                                    HStack {
                                        Text("\(transaction.description)")
                                        Spacer()
                                        Text(String(format:"%.2f EUR", transaction.amount))
                                            .padding(.trailing, 20)
                                    }.padding(.bottom, 5)
                                }
                            }
                        }
                    },
                    label: {
                        HStack {
                            Text(debitor.name)
                            Spacer()
                            Text(String(format: "%.2f EUR", debitor.debtAmount))
                        }

                    }
                )
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Debitors")
    }
}

#Preview {
    DebtInfoView(debtManager: DebtManager())
}
