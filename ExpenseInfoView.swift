//
//  ExpenseInfoView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 20.09.23.
//

import SwiftUI

struct ExpenseInfoView: View {
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    
    var body: some View {
        VStack {
            Text("Test")
            BarChartView(moneyManager: moneyManager, dateManager: dateManager)
        }
    }
}

struct ExpenseInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseInfoView(moneyManager: MoneyManager(), dateManager: DateManager())
    }
}
