//
//  MonthlyPaymentsView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 03.10.23.
//

import SwiftUI

struct MonthlyPaymentsView: View {
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    
    @State var isShowingAddSubscriptionView = false
    
    var body: some View {
        Form {
            Section(header: Text("current Payments")) {
                ForEach(moneyManager.monthlySubscriptions, id: \.id) { subscription in
                    HStack {
                        Text(String(subscription.description))
                        Spacer()
                        Text(String(subscription.amount))
                        Image(systemName: "chevron.right")
                    }
                    
                }
            }
        }.navigationTitle("Monthly Payments")
            .navigationBarItems(
                trailing: 
                    NavigationLink(destination: AddSubscriptionView(moneyManager: moneyManager, dateManager: dateManager), isActive: $isShowingAddSubscriptionView) {
                        Button("Add") {
                            isShowingAddSubscriptionView.toggle()
                }
                })
    }
}

#Preview {
    MonthlyPaymentsView(moneyManager: MoneyManager(), dateManager: DateManager())
}
