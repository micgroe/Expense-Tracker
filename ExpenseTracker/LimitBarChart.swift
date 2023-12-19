//
//  LimitBarChart.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 04.12.23.
//

import SwiftUI
import Charts

struct LimitBarChart: View {
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    var category: String
    
    var displayedMonths: Int
    
    var body: some View {
        Chart {
            ForEach(categoryManager.getCategoryBars(moneyManager: moneyManager, category: category, months: displayedMonths, month: dateManager.selectedMonth, year: dateManager.selectedYear).sorted(by: { $0.month < $1.month }), id: \.id) { limit in
                
                BarMark(x: .value("Month", limit.formattedDate),
                        y: .value("EUR", limit.currentLimit),
                        width: MarkDimension(floatLiteral: 20))
                .foregroundStyle(.red)
                
                RuleMark(y: .value("EUR", categoryManager.getAverage(categoryBars: categoryManager.getCategoryBars(moneyManager: moneyManager, category: category, months: displayedMonths, month: dateManager.selectedMonth, year: dateManager.selectedYear))))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 10]))
                    .foregroundStyle(.green)
                    .annotation(position: .trailing) {
                        Text("avg")
                            .font(.system(size: 13))
                            .foregroundColor(.green)
                        
                    }
                RuleMark(y: .value("EUR", limit.maxLimit))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 10]))
                    .annotation(position: .trailing) {
                        Text("limit")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
            }
        }
        .chartYScale(domain: [0, categoryManager.getYAxis(categoryBars: categoryManager.getCategoryBars(moneyManager: moneyManager, category: category, months: displayedMonths, month: dateManager.selectedMonth, year: dateManager.selectedYear))])
        .chartYAxis {
            AxisMarks(values: [0])
        }
    }
}

#Preview {
    LimitBarChart(categoryManager: CategoryManager(), moneyManager: MoneyManager(), dateManager: DateManager(), category: "Alcohol", displayedMonths: 3)
}
