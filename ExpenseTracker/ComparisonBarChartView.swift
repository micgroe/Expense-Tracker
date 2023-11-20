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
            ForEach(moneyManager.filteredSixMonths, id: \.id) { expense in
                BarMark(x: .value("Day", expense.formattedDate),
                        y: .value("Expense", expense.amount)
                )
                .cornerRadius(3)
                .foregroundStyle(by: .value("Category", expense.category!))
                .foregroundStyle(currentActiveItem?.id == expense.id ? .green : .blue)
                if let currentActiveItem, currentActiveItem.id == expense.id {
                    RuleMark(x: .value("Day", currentActiveItem.day))
                        .annotation(position: .top) {
                            HStack(spacing: 6) {
                                Text("\(currentActiveItem.day). \(Calendar.current.shortMonthSymbols[dateManager.currentMonth-1])")
                                Spacer()
                                Text(String(format: "%.2f EUR",currentActiveItem.expense))
                            }.padding(.horizontal, 7)
                                .padding(.vertical, 7)
                                .background{
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(.green)
                                }
                        }
                }
            }
        }
//        .chartXScale(domain: [dateManager.currentMonth-6, dateManager.currentMonth])
//        .chartYScale(domain: [1, Int(round(moneyManager.getMaxSixMonthAmount(bars: moneyManager.sixMonthGroupedBars))*1.1)])
//            .chartYAxis {
//                AxisMarks(values: [0, Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*0.36), Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*0.73), Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*1.1)])
//            }
//            .chartXAxis {
//                AxisMarks(values: .automatic(desiredCount: 6))
//            }
            .chartOverlay(content: { proxy in
                GeometryReader { innerProxy in
                    Rectangle()
                        .fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let location = value.location
                                    
                                    if let day: Int = proxy.value(atX: location.x) {
                                        if let currentItem = moneyManager.sixMonthGroupedBars.first(where: { item in
                                            item.day == day
                                        }) {
                                            currentActiveItem = currentItem
                                            plotWidth = proxy.plotAreaSize.width
                                        }
                                    }
                                }.onEnded { value in
                                    currentActiveItem = nil
                                })
                }
                
            })
            .frame(height: 150)
    }
}

#Preview {
    ComparisonBarChartView(moneyManager: MoneyManager(), dateManager: DateManager())
}
