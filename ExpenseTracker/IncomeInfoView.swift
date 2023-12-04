//
//  IncomeInfoView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 29.11.23.
//

import SwiftUI

struct IncomeInfoView: View {
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    @ObservedObject var incomeManager: IncomeManager
    
    @State var currentTab: Int = 3
    
    var body: some View {
        VStack {
            Picker("", selection: $currentTab) {
                Text("3 months").tag(3)
                Text("6 months").tag(6)
                Text("This year").tag(dateManager.currentMonth)
            }.pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            VStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Income")
                                .foregroundColor(.green)
                            Text(String(format: "%.2f EUR", incomeManager.getAggregatedSum(aggregatedIncomes: incomeManager.getAggregatedMonths(months: currentTab, dateManager: dateManager))))
                                .font(.system(size: 15))
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Total Expenses")
                                .padding(.trailing)
                                .foregroundColor(.red)
                            Text(String(format: "%.2f EUR", incomeManager.getAggregatedSum(aggregatedIncomes: moneyManager.getAggregatedMonths(months: currentTab, dateManager: dateManager))))
                                .font(.system(size: 15))
                        }
                        Spacer()
                    }.padding(.bottom)
                    IncomeComparisonChart(moneyManager: moneyManager, dateManager: dateManager, incomeManager: incomeManager, showingMonths: currentTab).frame(height: 150)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Money saved")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            Text("\(incomeManager.calcAverageSavings(income: incomeManager.getAggregatedSum(aggregatedIncomes: incomeManager.getAggregatedMonths(months: currentTab, dateManager: dateManager)), expense: incomeManager.getAggregatedSum(aggregatedIncomes: moneyManager.getAggregatedMonths(months: currentTab, dateManager: dateManager)))) %")
                        }
                        Spacer()
                    }
                }.padding()
            }.background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.secondarySystemBackground))
            }
            Spacer()
        }
    }
}

#Preview {
    IncomeInfoView(moneyManager: MoneyManager(), dateManager: DateManager(), incomeManager: IncomeManager())
}
