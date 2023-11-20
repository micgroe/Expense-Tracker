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
    
    @State var currentTab: String = "6 months"
    
    var body: some View {
        Picker("", selection: $currentTab) {
            Text("6 months").tag("6 months")
            Text("3 months").tag("3 months")
            Text("this Month").tag("this Month")
        }.pickerStyle(.segmented)
        .padding(.horizontal)
        
        Form {
            Section(header: Text("Comparison")) {
                VStack {
                    ComparisonBarChartView(moneyManager: moneyManager, dateManager: dateManager)
                }
            }
            Section(header: Text("Categories")) {
                ForEach(moneyManager.categoryTotals) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .frame(width: 18, height: 18)
                        VStack(alignment: .leading) {
                            Text("\(category.category)")
                            HStack {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: CGFloat(category.totalAmount / moneyManager.totalAmount) * 220, height: 5)
                                Text(String(format: "%.2f EUR", category.totalAmount))
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
        ExpenseComparisonView(moneyManager: MoneyManager(), dateManager: DateManager())
    }
}
