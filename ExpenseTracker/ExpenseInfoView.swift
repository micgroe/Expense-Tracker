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
    @ObservedObject var monthlyPaymentManager: MonthlyPaymentManager
    @ObservedObject var categoryManager: CategoryManager
    
    let backgroundColor = Color(.systemBackground)
    let secondaryColor = Color(.secondarySystemBackground)
    let tertiaryColor = Color(.tertiarySystemBackground)
    
    @State var amount: String = ""
    @State var isShowingComparisonView = false
    @State var isShowingAddSubscriptionView = false
    
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM" // Customize the date format
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
//            ScrollView {
                VStack {
                    HStack {
                        Image(systemName: "chevron.left")
                            .padding(.leading, 40)
                            .onTapGesture {
                                dateManager.selectedMonth -= 1
                                moneyManager.updateMonthlyTransactions(selectedMonth: dateManager.currentMonth, selectedYear: dateManager.currentYear, transactionType: "Expense")
                                moneyManager.updateMonthlyTransactionSum(monthlyTransactions: moneyManager.monthlyExpenses, transactionType: "Expense")
                                moneyManager.updateGroupedExpenses(dateManager.currentMonth, dateManager.currentYear)
                            }
                        Spacer()
                        Text("\(dateManager.getMonthName(month: dateManager.selectedMonth))").font(.system(size: 25, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 40)
                            .onTapGesture {
                                dateManager.selectedMonth += 1
                                moneyManager.updateMonthlyTransactions(selectedMonth: dateManager.currentMonth, selectedYear: dateManager.currentYear, transactionType: "Expense")
                                moneyManager.updateMonthlyTransactionSum(monthlyTransactions: moneyManager.monthlyExpenses, transactionType: "Expense")
                                moneyManager.updateGroupedExpenses(dateManager.currentMonth, dateManager.currentYear)
                            }
                    }
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Expenses this month")
                                    .font(.system(size: 13))
                                    .padding(.top, 10)
                                Text(String(format: "%.2f EUR", moneyManager.getSelectedMonthSum(dateManager: dateManager)))
                                    .font(.system(size: 20, weight: .bold))
                                    .padding(.top, 4)
                            }
                            .padding(.leading)
                            Spacer()
                            if let percentChange = moneyManager.getPercentageDifference(dateManager.currentMonth, dateManager.currentYear) {
                                Image(systemName: percentChange > 0 ? "arrow.down.circle" : "arrow.up.circle")
                                    .foregroundColor(Color.gray)
                                Text("\(Int(round(percentChange)))% from last month")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                        }
                        BarChartView(moneyManager: moneyManager, dateManager: dateManager)
                            .padding(.horizontal)
                            .padding(.bottom)
                        Divider()
                            .padding(.leading)
                        HStack {
                                NavigationLink(destination: ExpenseComparisonView(moneyManager: moneyManager, dateManager: dateManager), isActive: $isShowingComparisonView) {
                                        Button("See more info", action: {
                                            moneyManager.updateFilteredSixMonthExpenses(dateManager.currentMonth, dateManager.currentYear)
                                            moneyManager.updateCategoryTotals(transactions: moneyManager.filteredSixMonths)
                                            moneyManager.updateTotalAmount(transactions: moneyManager.filteredSixMonths)
                                            isShowingComparisonView.toggle()
                                })
                            }
                            .foregroundColor(Color.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.gray)
                        }.frame(height: 35)
                            .padding(.horizontal)
                        
                    }.background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(secondaryColor)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            NavigationLink(destination: MonthlyPaymentsView(monthlyPaymentManager: monthlyPaymentManager, dateManager: dateManager, categoryManager: categoryManager), isActive: $isShowingAddSubscriptionView) {
                                Button("Manage monthly payments", action: {
                                    isShowingAddSubscriptionView.toggle()
                                })
                            }.foregroundColor(Color.white)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(Color.gray)
                        }.frame(height: 45)
                    }.padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(secondaryColor))
                        .padding(.top)
                    
                }.padding(.horizontal)
            VStack {
                HStack {
                    Text("All expenses")
                        .font(.system(size: 25, weight: .bold))
                        .padding(.leading, 9)
                    Spacer()
                }
                ScrollView {
                    ForEach(moneyManager.getAggregatedDays(dateManager: dateManager).sorted(by: { $0.day > $1.day } )) { day in
                        HStack {
                            Text("\(day.day) \(Calendar.current.shortMonthSymbols[dateManager.selectedMonth-1])")
                                .foregroundColor(.gray)
                                .padding(.leading, 11)
                            Spacer()
                        }.padding(.bottom, -3)
                        VStack(spacing: 0) {
                            ForEach(moneyManager.getCurrentDayExpenses(dateManager: dateManager, day: day.day), id: \.id) { transaction in
                                HStack(alignment: .center) {
                                    Text("\(transaction.description)")
                                    Spacer()
                                    Text("- \(transaction.amount, specifier: "%.2f") EUR")
                                        .foregroundColor(.red)
                                        .padding(.trailing)
                                }.padding(.vertical, 12)
                                    .padding(.leading)
                                if transaction != moneyManager.getCurrentDayExpenses(dateManager: dateManager, day: day.day).last {
                                    Divider()
                                }
                            }
                        }.background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.secondarySystemBackground))
                        }.padding(.bottom, 5)
                    }
                }
            }.padding()
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct ExpenseInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseInfoView(moneyManager: MoneyManager(), dateManager: DateManager(), monthlyPaymentManager: MonthlyPaymentManager(), categoryManager: CategoryManager())
    }
}
