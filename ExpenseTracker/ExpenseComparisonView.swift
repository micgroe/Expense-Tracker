//
//  ExpenseComparisonView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 24.09.23.
//

import SwiftUI

struct ExpenseComparisonView: View {
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    @ObservedObject var categoryManager: CategoryManager
    
    var body: some View {
        Form {
            Section(header: Text("chart")) {
                VStack {
                    HStack {
                        Image(systemName: "chevron.left")
                            .onTapGesture {
                                let add = "Sub"
                                dateManager.updateSelectedMonth(operation: add)
                            }
                        Text("\(dateManager.getMonthName(month: dateManager.selectedMonth))")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal)
                        Image(systemName: "chevron.right")
                            .onTapGesture {
                                let add = "Add"
                                dateManager.updateSelectedMonth(operation: add)
                            }
                    }
                    Divider()
                    VStack {
                        ComparisonBarChartView(moneyManager: moneyManager, dateManager: dateManager)
                            .frame(height: 160)
                    }
                }

            }
            Section(header: Text("Categories")) {
                ForEach(moneyManager.getCategoryComparisonBars(dateManager: dateManager), id: \.category) { category in
                    let totalSum = moneyManager.getMonthlyExpenseSum(dateManager.selectedMonth, dateManager.selectedYear)
                    HStack {
                        Image(systemName: categoryManager.categoryIcons[category.category] ?? "")
                            .frame(width: 18, height: 18)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(category.category)")
                                .padding(.bottom, 3)
                            HStack {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: CGFloat(category.amount / totalSum) * 190, height: 5)
                                    .cornerRadius(5)
                                Text(String(format: "%.2f EUR", category.amount))
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 12))
                            }
                        }.padding(.leading, 9)
                    }
                }
            }
        }
    }
}

struct ExpenseComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseComparisonView(moneyManager: MoneyManager(), dateManager: DateManager(), categoryManager: CategoryManager())
    }
}
