//
//  FilterExpenseView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 13.09.23.
//

import SwiftUI

struct FilterExpenseView: View {
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    
    let columns = [
            GridItem(.adaptive(minimum: 80))
        ]
    let months: [String] = Calendar.current.shortMonthSymbols
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.left")
                    .frame(width: 24.0)
                    .onTapGesture {
                        dateManager.currentYear -= 1;
                    }
                Text("\(dateManager.currentYear)").foregroundColor(.white)
                         .transition(.move(edge: .trailing))
                Spacer()
                Image(systemName: "chevron.right")
                    .frame(width: 24.0)
                    .onTapGesture {
                        dateManager.currentYear += 1;
                    }
            }.padding(.all, 12.0)
            .background(Color.blue)
            
            // Month Picker
            LazyVGrid(columns: columns, spacing: 20) {
                let selectedMonthSymbol: String = months[dateManager.currentMonth-1]
                ForEach(months, id: \.self) { item in
                    Text(item)
                        .frame(width: 60, height: 33)
                        .background(item == selectedMonthSymbol ? Color.blue : Color("buttonBackground"))
                        .cornerRadius(8)
                        .onTapGesture {
                            dateManager.currentMonth = (months.firstIndex(where: { $0 == item }) ?? 0) + 1
                        }
                }
            }

            Button("Confirm") {
                moneyManager.updateMonthlyTransactions(selectedMonth: dateManager.currentMonth, selectedYear: dateManager.currentYear, transactionType: "All")
                moneyManager.updateCategoryBalancesForMonth()
                moneyManager.updateMonthlyTransactionSum(monthlyTransactions: moneyManager.monthlyTransactions, transactionType: "All")
                presentationMode.wrappedValue.dismiss()
            }
            Spacer()
        }
    }
}

struct FilterExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        FilterExpenseView(moneyManager: MoneyManager(), dateManager: DateManager())
    }
}
