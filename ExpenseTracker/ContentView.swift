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
    
    @State private var selectedOption: String? = nil
    
    var body: some View {
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
                        NavigationLink(destination: ExpenseInfoView(moneyManager: moneyManager, dateManager: dateManager), isActive: $isShowingExpenseInfo) {
                            RectView(backgroundColor: secondaryColor, numberColor: Color.red, title: "Expenses", number: String(format: "%.2f EUR", moneyManager.getCurrentMonthSum(dateManager: dateManager))).onTapGesture {
                                moneyManager.updateGroupedExpenses(dateManager.currentMonth, dateManager.currentYear)
                                isShowingExpenseInfo.toggle()
                            }
                        }
                        RectView(backgroundColor: secondaryColor, numberColor: Color.green, title: "Income", number: String(format: "%.2f EUR", moneyManager.monthlyIncomeSum))
                    }.padding(.horizontal)
                    HStack {
                        NavigationLink(destination: DebtInfoView(debtManager: debtManager, moneyManager: moneyManager, dateManager: dateManager), isActive: $isShowingDebtInfo) {
                            RectView(backgroundColor: secondaryColor, numberColor: Color.gray, title: "Debts", number: String(format: "%.2f EUR", debtManager.totalDebts)).onTapGesture {
                                isShowingDebtInfo.toggle()
                            }
                            
                        }
                        RectView(backgroundColor: secondaryColor, numberColor: Color.gray, title: "Credits", number: String(format: "%.2f EUR", moneyManager.creditAmount))
                        }.padding(.horizontal)
                    HStack {
                        Text("\(dateManager.getMonthName(month: dateManager.currentMonth))")
                            .font(.system(size: 30, weight: .bold))
                            .padding(.leading)
                            .foregroundColor(Color.white)
                        Button(action: {
                            showingFilterSheet.toggle()
                        }, label: {
                            Image(systemName: "pencil.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 27, height: 27)
                                .padding(.leading, 5)
                        })
                        Spacer()
                    }.background(backgroundColor)
                    .padding(.top)
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
        }.onAppear{
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
                AddExpenseView(moneyManager: moneyManager, dateManager: dateManager, selectedOption: selectedOption)
            }
        })
        .sheet(isPresented: $showingAddIncomeSheet, content: {
            NavigationView {
                AddIncomeView(moneyManager: moneyManager, dateManager: dateManager, selectedOption: selectedOption)
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

struct RectView: View {
    var backgroundColor: Color
    var numberColor: Color
    var title: String
    var number: String
    
    let headlineSize: CGFloat = 23
    let numberSize: CGFloat = 35
    let rectCornerRadius: CGFloat = 15
    
    var body: some View {
            VStack(alignment: .leading) {
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
            }.background {
                RoundedRectangle(cornerRadius: rectCornerRadius)
                    .fill(backgroundColor)
            }.frame(width: 190, height: 190)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
