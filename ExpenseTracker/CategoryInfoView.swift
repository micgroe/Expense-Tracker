//
//  CategoryInfoView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 08.12.23.
//

import SwiftUI

struct CategoryInfoView: View {
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    
    @State private var isShowingAddLimit: Bool = false
//    @State private var isShowingLimitEdit: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                let screenWidth = geometry.size.width
                Form {
                    Section {
                        NavigationLink(destination: AddLimitView(categoryManager: categoryManager), isActive: $isShowingAddLimit) {
                            HStack {
                                Text("Add new limit")
                                Spacer()
                            }.onTapGesture {
                                isShowingAddLimit.toggle()
                            }
                        }
                    }
                    if !categoryManager.categoryLimits.isEmpty {
                        Section(header: Text("All limits")) {
                            ForEach(categoryManager.categoryLimits.sorted(by: { $0.key < $1.key }), id: \.key) { (category, limit) in
                                let isShowingLimitEdit = Binding.constant(false)
                                NavigationLink(destination: LimitEditView(categoryManager: categoryManager, moneyManager: moneyManager, dateManager: dateManager, category: category), isActive: isShowingLimitEdit) {
                                        LimitView(categoryManager: categoryManager, moneyManager: moneyManager, category: category, screenWidth: screenWidth)
                                            .onTapGesture {
                                                isShowingLimitEdit.wrappedValue = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LimitView: View {
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var moneyManager: MoneyManager
    let category: String
    let screenWidth: Double
    let maxPercent = 0.45
    
    private func getLineMultiplier(multiplier: Double) -> Double {
        if multiplier >= 1 {
            return 1
        } else {
            return multiplier
        }
    }
    
    var body: some View {
        let maxLimit = categoryManager.categoryLimits[category]
        let currentAmountLine = categoryManager.calcLimitPercentage(moneyManager: moneyManager, category: category, limit: maxLimit ?? 0)
        let categoryIcon = categoryManager.categoryIcons[category]!
        
        HStack {
            Image(systemName: categoryIcon)
                .frame(width: 18, height: 18)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 3) {
                Text(category)
                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: screenWidth * maxPercent * getLineMultiplier(multiplier: currentAmountLine), height: 6)
                        .cornerRadius(3)
                        .padding(.trailing, -3)
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: screenWidth * maxPercent * (1-getLineMultiplier(multiplier: currentAmountLine)), height: 6)
                        .cornerRadius(3)
                    Text(String(format: "%.2f EUR ", maxLimit ?? 0))
                        .font(.system(size: 12))
                        .padding(.leading, 5)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    CategoryInfoView(categoryManager: CategoryManager(), moneyManager: MoneyManager(), dateManager: DateManager())
}
