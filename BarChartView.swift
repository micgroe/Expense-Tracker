//
//  BarChartView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 20.09.23.
//

import SwiftUI
import Charts

struct BarChartView: View {
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    
    @State var currentActiveItem: Bar?
    @State var plotWidth: CGFloat = 0
    
    var body: some View {
        Chart {
            ForEach(moneyManager.groupedBars, id: \.day) { expense in
                BarMark(x: .value("Day", expense.day),
                        y: .value("Expense", expense.expense)
                )
                .cornerRadius(3)
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
        }.chartXScale(domain: [1, moneyManager.groupedBars.count])
            .chartYScale(domain: [1, Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*1.1)])
        .chartYAxis {
            AxisMarks(values: [0, Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*0.36), Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*0.73), Int(round(moneyManager.groupedExpenses.values.max() ?? 0)*1.1)])
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6))
        }
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                
                                if let day: Int = proxy.value(atX: location.x) {
                                    if let currentItem = moneyManager.groupedBars.first(where: { item in
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

struct Bar: Identifiable {
    let id = UUID()
    var day: Int
    var expense: Double
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(moneyManager: MoneyManager(), dateManager: DateManager())
    }
}
