//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 10.09.23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var moneyManager = MoneyManager()
    @ObservedObject var dateManager = DateManager()
    @ObservedObject var debtManager = DebtManager()
    @ObservedObject var incomeManager = IncomeManager()
    @ObservedObject var categoryManager = CategoryManager()
    @ObservedObject var monthlyPaymentManager = MonthlyPaymentManager()
    
    let colors = [Color.green, Color.red, Color.yellow, Color.blue, Color.orange, Color.black, Color.pink]
    let backgroundColor = Color(.systemBackground)
    let secondaryColor = Color(.secondarySystemBackground)
    let tertiaryColor = Color(.tertiarySystemBackground)
    
    
    @State private var showingAddTransactionSheet = false
    @State private var showingAddDebtSheet = false
    @State private var showingAddIncomeSheet = false
    @State private var showingFilterSheet = false
    @State private var isShowingOptions = false
    
    @State private var isShowingExpenseInfo = false
    @State private var isShowingDebtInfo = false
    @State private var isShowingIncomeInfo = false
    @State private var isShowingCategoryEdit = false
    
    @State private var selectedOption: String? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            NavigationStack {
                ZStack(alignment: .top) {
                    VStack {
                        HStack {
                            Text("Expense Tracker")
                                .font(.system(size: 35, weight: .bold))
                                .padding(.leading, 25)
                                .padding(.top, 40)
                            Spacer()
                        }
                        HStack {
                            NavigationLink(destination: ExpenseInfoView(moneyManager: moneyManager, dateManager: dateManager, monthlyPaymentManager: monthlyPaymentManager, categoryManager: categoryManager), isActive: $isShowingExpenseInfo) {
                                RectView(backgroundColor: secondaryColor, numberColor: Color.red, title: "Expenses", number: String(format: "%.2f EUR", moneyManager.getCurrentMonthSum(dateManager: dateManager)), screenWidth: screenWidth).onTapGesture {
                                    moneyManager.updateGroupedExpenses(dateManager.currentMonth, dateManager.currentYear)
                                    isShowingExpenseInfo.toggle()
                                }
                            }
                            NavigationLink(destination: IncomeInfoView(moneyManager: moneyManager, dateManager: dateManager, incomeManager: incomeManager), isActive: $isShowingIncomeInfo) {
                                RectView(backgroundColor: secondaryColor, numberColor: Color.green, title: "Income", number: String(format: "%.2f EUR", incomeManager.getCurrentMonthSum(dateManager: dateManager)), screenWidth: screenWidth).onTapGesture {
                                    isShowingIncomeInfo.toggle()
                                }
                            }
                        }
                        HStack {
                            NavigationLink(destination: DebtInfoView(debtManager: debtManager, moneyManager: moneyManager, dateManager: dateManager, categoryManager: categoryManager), isActive: $isShowingDebtInfo) {
                                RectView(backgroundColor: secondaryColor, numberColor: Color.gray, title: "Debts", number: String(format: "%.2f EUR", debtManager.totalDebts), screenWidth: screenWidth).onTapGesture {
                                    isShowingDebtInfo.toggle()
                                }
                                
                            }
                            RectView(backgroundColor: secondaryColor, numberColor: Color.gray, title: "Credits", number: String(format: "%.2f EUR", moneyManager.creditAmount), screenWidth: screenWidth)
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Limits")
                                    .font(.system(size: 22, weight: .bold))
                                Spacer()
                                Button("Edit") {
                                    isShowingCategoryEdit.toggle()
                                }.padding(.trailing)
                            }
                            if !categoryManager.categoryLimits.isEmpty {
                                ScrollView {
                                    ForEach(categoryManager.categoryLimits.sorted(by: { $0.key < $1.key }), id: \.key) { (category, limit) in
//                                    ForEach(categoryManager.categoryLimits.sortedKeysAndValues(by: { ($0.value - categoryManager.categorySums[$0.key]) < ($1.value - categoryManager.categorySums[$1.key]) }), id: \.key) { (category, limit) in
//                             TODO: Sort by remaining limit
                                        CategoryLimitView(categoryManager: categoryManager, category: category, screenWidth: screenWidth)
                                    }
                                }
                            } else {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("No limits added yet!")
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                Spacer()
                            }
                            Spacer()
                        }.frame(height: 160)
                        .padding(.leading)
                        .padding(.top)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(secondaryColor)
                        }
                        Spacer()
                    }
                    ZStack {
                        VStack {
                            Spacer()
                            HStack{
                                Spacer()
                                Menu {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            selectedOption = "Credit"
                                        }
                                        showingAddIncomeSheet.toggle()
                                    }) {
                                        Text("Add Credit")
                                    }
                                    Button(action: {
                                        showingAddDebtSheet.toggle()
                                    }) {
                                        Text("Add Debt")
                                    }
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            selectedOption = "Income"
                                        }
                                        showingAddIncomeSheet.toggle()
                                    }) {
                                        Text("Add Income")
                                    }
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            selectedOption = "Expense"
                                        }
                                        showingAddTransactionSheet.toggle()
                                    }) {
                                        Text("Add Expense")
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .padding(.trailing, 15)
                                        .padding(.bottom)
                                }
                            }
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
            }.onAppear {
                for payment in monthlyPaymentManager.monthlyPayments {
                    if monthlyPaymentManager.newMonthHasBegun(monthlyPayment: payment, dateManager: dateManager) {
                        monthlyPaymentManager.addTransaction(monthlyPayment: payment, moneyManager: moneyManager, categoryManager: categoryManager)
                    }
                }
                moneyManager.updateMonthlyTransactions(selectedMonth: dateManager.currentMonth, selectedYear: dateManager.currentYear, transactionType: "Expense")
                moneyManager.updateMonthlyTransactionSum(monthlyTransactions: moneyManager.monthlyExpenses, transactionType: "Expense")
                moneyManager.updateMonthlyTransactions(selectedMonth: dateManager.currentMonth, selectedYear: dateManager.currentYear, transactionType: "Income")
                moneyManager.updateMonthlyTransactionSum(monthlyTransactions: moneyManager.monthlyExpenses, transactionType: "Income")
                moneyManager.updateDebts()
                moneyManager.updateDebtAmount()
                moneyManager.updateCredits()
                moneyManager.updateCreditAmount()
            }
            .sheet(isPresented: $showingAddTransactionSheet, content: {
                NavigationView {
                    AddExpenseView(moneyManager: moneyManager, dateManager: dateManager, categoryManager: categoryManager, selectedOption: selectedOption)
                }
            })
            .sheet(isPresented: $isShowingCategoryEdit, content: {
                NavigationView {
                    CategoryEditView(categoryManager: categoryManager)
                }
            })
            .sheet(isPresented: $showingAddIncomeSheet, content: {
                NavigationView {
                    AddIncomeView(moneyManager: moneyManager, dateManager: dateManager, incomeManager: incomeManager)
                }
            })
            .sheet(isPresented: $showingFilterSheet, content: {
                NavigationView {
                    FilterExpenseView(moneyManager: moneyManager, dateManager: dateManager)
                }
            })
            .sheet(isPresented: $showingAddDebtSheet, content: {
                NavigationView {
                    AddDebtView(moneyManager: moneyManager, dateManager: dateManager, debtManager: debtManager)
                }
            })
        }
    }
}

struct RectView: View {
    var backgroundColor: Color
    var numberColor: Color
    var title: String
    var number: String
    let screenWidth: Double
    
    let headlineSize: CGFloat = 23
    let numberSize: CGFloat = 35
    let rectCornerRadius: CGFloat = 15
    
    let widthPercent = 0.49
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Spacer()
                    Text(title)
                        .font(.system(size: headlineSize, weight: .bold))
                        .padding(.top, 15)
                        .foregroundColor(.white)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(number)
                        .foregroundColor(numberColor)
                        .font(.system(size: numberSize))
                    Spacer()
                }
                Spacer()
            }
        }.background {
            RoundedRectangle(cornerRadius: rectCornerRadius)
                .fill(backgroundColor)
        }.frame(width: screenWidth * widthPercent, height: screenWidth * widthPercent)
    }
}

struct CategoryLimitView: View {
    let categoryManager: CategoryManager
    let category: String
    let screenWidth: Double
    let maxPercent = 0.51
    
    private func getLineColor(percentage: Double) -> Color {
        if percentage <= 0.33 {
            return Color.green
        } else if percentage > 0.33 && percentage <= 0.67 {
            return Color.yellow
        } else if percentage > 0.67 && percentage < 1 {
            return Color.orange
        } else {
            return Color.red
        }
    }
    
    private func getLineMultiplier(multiplier: Double) -> Double {
        if multiplier >= 1 {
            return 1
        } else {
            return multiplier
        }
    }
    
    var body: some View {
        let maxLimit = categoryManager.categoryLimits[category]
        let currentLimit = categoryManager.categorySums[category]
        let currentAmountLine = categoryManager.calcLimitPercentage(category: category, limit: maxLimit!)
        let categoryIcon = categoryManager.categoryIcons[category]!
        let remainingLimit = categoryManager.getRemainingLimit(maxLimit: maxLimit!, currentLimit: currentLimit ?? 0)
        
        HStack {
            VStack{
                Image(systemName: categoryIcon)
            }.frame(width: 21)
            .padding(.leading, 5)
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundColor(getLineColor(percentage: currentAmountLine))
                    .frame(width: screenWidth * maxPercent * getLineMultiplier(multiplier: currentAmountLine), height: 2)
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: screenWidth * maxPercent * (1-getLineMultiplier(multiplier: currentAmountLine)), height: 2)
            }.padding(.leading, 5)
            Spacer()
            if remainingLimit <= 0 {
                Text("Limit reached!")
                    .font(.system(size: 14))
                    .padding(.trailing)
                    .foregroundColor(.red)
            } else {
                Text(String(format: "%.2f EUR left", remainingLimit))
                    .font(.system(size: 14))
                    .padding(.trailing)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
