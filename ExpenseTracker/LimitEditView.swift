//
//  LimitEditView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 09.12.23.
//

import SwiftUI

struct LimitEditView: View {
    @ObservedObject var categoryManager: CategoryManager
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    
    @State var displayedMonths: Int = 3
    @State private var showEditAlert = false
    @State private var newLimit: String = ""
    @State private var showDeleteAlert = false
    @State private var isDeleted = false
    
    let category: String
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {

//            Section(header: Text("Category")) {
//                VStack {
//                    HStack {
//                        Image(systemName: categoryManager.categoryIcons[category] ?? "No category")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .padding(.horizontal)
//                        Text(category)
//                            .font(.system(size: 40, weight: .bold))
//                        Spacer()
//                    }.frame(height: 50)
//                }.frame(height: 90)
//            }
            Section(header: Text(category)) {
                Picker("", selection: $displayedMonths) {
                    Text("3 months").tag(3)
                    Text("6 months").tag(6)
                    Text("This year").tag(dateManager.currentMonth)
                }.pickerStyle(.segmented)
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Text("Monthly Average")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                            Text(String(format: "%.2f EUR", categoryManager.getAverage(categoryBars: categoryManager.getCategoryBars(moneyManager: moneyManager, category: category, months: displayedMonths, month: dateManager.selectedMonth, year: dateManager.selectedYear))))
                        }
                        Spacer()
                        if categoryManager.categoryLimits[category] ?? 0 < categoryManager.getAverage(categoryBars: categoryManager.getCategoryBars(moneyManager: moneyManager, category: category, months: displayedMonths, month: dateManager.selectedMonth, year: dateManager.selectedYear)) {
                            Text("Exceeded by \(categoryManager.getLimitPercentage(category: category, categoryBar: categoryManager.getCategoryBars(moneyManager: moneyManager, category: category, months: displayedMonths, month: dateManager.selectedMonth, year: dateManager.selectedYear)))%")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        } else {
                            Text("\(categoryManager.getLimitPercentage(category: category, categoryBar: categoryManager.getCategoryBars(moneyManager: moneyManager, category: category, months: displayedMonths, month: dateManager.selectedMonth, year: dateManager.selectedYear)))% below limit")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }
                    }
                        .font(.system(size: 23, weight: .bold))
                    LimitBarChart(categoryManager: categoryManager, moneyManager: moneyManager, dateManager: dateManager, category: category, displayedMonths: displayedMonths)
                }.padding(.bottom, 5)
            }
            Section(header: Text("Details")) {
                HStack {
                    Text("Current limit")
                    Spacer()
                    Text(String(format: "%.2f EUR", categoryManager.categoryLimits[category] ?? 0))
                }
                HStack {
                    Text("Spent this month")
                    Spacer()
                    Text(String(format: "%.2f EUR", categoryManager.getCurrentMonthCategorySum(moneyManager: moneyManager, category: category)))
                }
            }
            Section {
                Text("Edit current limit")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        showEditAlert.toggle()
                    }
                Text("Delete limit")
                    .foregroundColor(.red)
                    .onTapGesture {
                        showDeleteAlert.toggle()
                    }
            }
        }.alert("Enter new limit", isPresented: $showEditAlert) {
            TextField("New limit", text: $newLimit)
            Button("Change limit") {
                if let amount = Double(newLimit) {
                    categoryManager.updateCategoryLimit(category: category, newLimit: amount)
                }
            }
            Button("Cancel", role: .cancel) {
                showEditAlert.toggle()
            }
        }
        .alert("Do you really want to delete the limit?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert.toggle()
            }
            Button("Delete", role: .destructive) {
//                categoryManager.categoryLimits.removeValue(forKey: category)
                isDeleted = true
                dismiss() //TODO: Find out why key can't be removed from limits array without problems
            }
        }.onDisappear {
            if isDeleted {
                categoryManager.removeCategoryLimit(category: category)
            }
        }
        Spacer()
    }
}

#Preview {
    LimitEditView(categoryManager: CategoryManager(), moneyManager: MoneyManager(), dateManager: DateManager(), category: "Alcohol")
}
