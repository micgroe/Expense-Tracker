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
    
    let colors = [Color.green, Color.red, Color.yellow, Color.blue, Color.orange, Color.black, Color.pink]
    let backgroundColor = Color(.systemBackground)
    let secondaryColor = Color(.secondarySystemBackground)
    let tertiaryColor = Color(.tertiarySystemBackground)
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // Customize the date format
        return formatter
    }()
    
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    @State private var isShowingOptions = false
    
    @State private var selectedOption: String? = nil
    
    var body: some View {
        NavigationView {
            TabView {
                ZStack {
                    VStack {
                        HStack {
                            RectView(backgroundColor: secondaryColor, numberColor: Color.red, title: "Expenses", number: String(format: "%.2f EUR", moneyManager.filteredSum))
                            RectView(backgroundColor: secondaryColor, numberColor: Color.green, title: "Income", number: "0.00 EUR")
                        }.padding(.horizontal)
                        HStack {
                            RectView(backgroundColor: secondaryColor, numberColor: Color.gray, title: "Debts", number: String(format: "%.2f EUR", moneyManager.debtAmount))
                            RectView(backgroundColor: secondaryColor, numberColor: Color.gray, title: "Credits", number: "0.00 EUR")
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
                        
                        List {
                            ForEach(moneyManager.filteredTransactions, id: \.self) { transaction in
                                HStack {
                                Text("\(transaction.date, formatter: dateFormatter)")
                                Text("\(transaction.description)")
                                Spacer()
                                Text("- \(transaction.amount, specifier: "%.2f") EUR").foregroundColor(.red)
                                }
                            }.onDelete { indices in
                                moneyManager.transactions.remove(atOffsets: indices)
                                moneyManager.filteredTransactions.remove(atOffsets: indices)
                                moneyManager.updateCategoryBalancesForMonth()
                                moneyManager.updateSelectedMonthBalance(transactions:  moneyManager.filteredTransactions)
                            }
                        }.cornerRadius(25)
                        .padding(.horizontal, 7)
                        .background(backgroundColor)
                    }
                    ZStack {
                        VStack {
                            Spacer()
                            HStack{
                                Spacer()
                                Menu {
                                    Button(action: {
                                        selectedOption = "Credit"
                                    }) {
                                    Text("Add Credit")
                                    }
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            selectedOption = "Debt"
                                        }
                                        showingAddSheet.toggle()
                                    }) {
                                        Text("Add Debt")
                                    }
                                    Button(action: {
                                        selectedOption = "Income"
                                    }) {
                                        Text("Add Income")
                                    }
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            selectedOption = "Expense"
                                        }
                                        showingAddSheet.toggle()
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
                }.tabItem {
                    Image(systemName: "house")
                }
                .background(backgroundColor)
            }.onAppear{
                moneyManager.updateFilteredTransactions(selectedMonth: dateManager.currentMonth, selectedYear: dateManager.currentYear)
                moneyManager.updateSelectedMonthBalance(transactions: moneyManager.filteredTransactions)
                moneyManager.updateDebtAmount()
            }
        }.navigationBarTitle("Your Title", displayMode: .automatic).foregroundColor(.white) // Add this line
        .navigationBarHidden(false)
        .sheet(isPresented: $showingAddSheet, content: {
            NavigationView {
                AddExpenseView(moneyManager: moneyManager, dateManager: dateManager, selectedOption: selectedOption)
            }
        })
        .sheet(isPresented: $showingFilterSheet, content: {
            NavigationView {
                FilterExpenseView(moneyManager: moneyManager, dateManager: dateManager)
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
        Rectangle()
            .fill(backgroundColor)
            .frame(width: 190, height:190)
            .cornerRadius(rectCornerRadius)
            .overlay(
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text(title)
                            .font(.system(size: headlineSize, weight: .bold))
                            .padding(.top, 15)
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
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
