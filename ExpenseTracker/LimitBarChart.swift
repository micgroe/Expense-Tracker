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
    
    var body: some View {
        Chart {
            ForEach(categoryManager.getCategoryBar(maxLimits: categoryManager.categoryLimits, currentLimits: categoryManager.categorySums), id: \.id) { limit in
                
                let isExceeded = categoryManager.limitIsExceeded(maxLimit: limit.maxLimit, currentLimit: limit.currentLimit)
                
                BarMark(x: isExceeded ? .value("EUR", limit.maxLimit) : .value("EUR", limit.currentLimit),
                        y: .value("Category", limit.category))
                .foregroundStyle(.red)
            }
            ForEach(categoryManager.getCategoryBar(maxLimits: categoryManager.categoryLimits, currentLimits: categoryManager.categorySums), id: \.id) { limit in
                
                let isExceeded = categoryManager.limitIsExceeded(maxLimit: limit.maxLimit, currentLimit: limit.currentLimit)
                
                BarMark(x: isExceeded ? .value("EUR", limit.maxLimit - limit.currentLimit) : .value("EUR", limit.currentLimit - limit.maxLimit),
                        y: .value("Category", limit.category))
                    .cornerRadius(3)
                    .foregroundStyle(isExceeded ? .gray : .white)
            }
        }.frame(height: 150)
    }
}

#Preview {
    LimitBarChart(categoryManager: CategoryManager())
}
