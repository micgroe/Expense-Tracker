//
//  IncomeComparisonChart.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 29.11.23.
//

import SwiftUI
import Charts

struct IncomeComparisonChart: View {
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    @ObservedObject var incomeManager: IncomeManager
    
    var showingMonths: Int
    
    var body: some View {
        Chart {
            ForEach(moneyManager.getAggregatedMonths(months: showingMonths, dateManager: dateManager)) { transaction in
                LineMark(x: .value("Day", transaction.day), //TODO: show each month with MMM formatting
                        y: .value("Expense", transaction.expense),
                         series: .value("Expense", "Expense")
                ).foregroundStyle(.red)
            }
            ForEach(incomeManager.getAggregatedMonths(months: showingMonths, dateManager: dateManager)) { income in
                LineMark(x: .value("Day", income.day),
                         y: .value("Expense", income.expense),
                         series: .value("Income", "Income")
                ).foregroundStyle(.green)
            }
        }.chartXScale(domain: [dateManager.currentMonth - showingMonths + 1, dateManager.currentMonth])
    }
}

#Preview {
    IncomeComparisonChart(moneyManager: MoneyManager(), dateManager: DateManager(), incomeManager: IncomeManager(), showingMonths: 3)
}
