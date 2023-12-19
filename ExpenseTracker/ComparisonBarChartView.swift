//
//  ComparisonBarChartView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 28.09.23.
//

import SwiftUI
import Charts

struct ComparisonBarChartView: View {
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    
    @State var currentActiveItem: Bar?
    @State var plotWidth: CGFloat = 0
    var body: some View {
        Chart {
            if !moneyManager.getCategoryComparisonBars(dateManager: dateManager).isEmpty {
                ForEach(moneyManager.getCategoryComparisonBars(dateManager: dateManager), id: \.category) { expense in
                    BarMark(x: .value("Category", expense.category),
                            y: .value("Expense", expense.amount)
                    )
                    .cornerRadius(3)
                    .foregroundStyle(by: .value("Category", expense.category))
                }
            } else {
                RuleMark(y: .value("Test", 0))
                    .annotation {
                        Text("No expenses added yet!")
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }.foregroundStyle(Color(.secondarySystemBackground))
            }
        }.chartLegend(.hidden)
//        .chartXScale(domain: [dateManager.currentMonth-6, dateManager.currentMonth])
//        .chartYScale(domain: [1, Int(round(moneyManager.getMaxSixMonthAmount(bars: moneyManager.sixMonthGroupedBars))*1.1)])
//            .chartYAxis {
//                AxisMarks(values: [0, Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*0.36), Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*0.73), Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*1.1)])
//            }
//            .chartXAxis {
//                AxisMarks(values: .automatic(desiredCount: 6))
//            }
    }
}

#Preview {
    ComparisonBarChartView(moneyManager: MoneyManager(), dateManager: DateManager())
}
