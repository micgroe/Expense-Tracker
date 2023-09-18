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
    
    let headlineSize: CGFloat = 23
    let rectCornerRadius: CGFloat = 15
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // Customize the date format
        return formatter
    }()
    
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    
    @State private var filteredTransactions: [Transaction] = []
    
    var body: some View {
        NavigationView {
            TabView {
                ZStack {
                    VStack {
                        HStack {
                            ZStack {
                                Rectangle()
                                    .fill(secondaryColor)
                                    .frame(width: 190, height:190)
                                    .cornerRadius(rectCornerRadius)
                                VStack() {
                                    HStack{
                                        Text("Money spent")
                                            .font(.system(size: headlineSize, weight: .bold))
                                            .padding(.top, 15)
                                            .padding(.leading, 15)
                                        Spacer()
                                    }

                                    
                                    Text("\(moneyManager.filteredSum, specifier: "%.2f")")
                                        .foregroundColor(.red)
                                        .font(.system(size: 35))
                                    Spacer()
                                }
                            }.padding(.leading)
                            Spacer()
                            ZStack {
                                Rectangle()
                                    .fill(secondaryColor)
                                    .frame(width: 190, height: 190)
                                    .cornerRadius(rectCornerRadius)
                                VStack(alignment: .leading) {
                                    HStack{
                                        Text("Top Categories")
                                            .font(.system(size: headlineSize, weight: .bold))
                                            .padding(.top, 15)
                                            .padding(.leading, 15)
                                        Spacer()
                                    }
                                    ForEach(Array(moneyManager.filteredCategoryBalances.prefix(5)), id: \.key) { (key, value) in
                                        HStack {
                                            Text(key)
                                            Text("\(value, specifier: "%.2f") EUR")
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }.padding(.trailing)
                        ZStack {
                            Rectangle()
                                .fill(secondaryColor)
                                .frame(width: 300, height: 190)
                                .cornerRadius(rectCornerRadius)
                            VStack(alignment: .leading) {
                                HStack{
                                    Text("Debts")
                                        .font(.system(size: headlineSize, weight: .bold))
                                        .padding(.top, 15)
                                        .padding(.leading, 15)
                                    Spacer()
                                }
                                if moneyManager.debts.isEmpty {
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Text("All debts paid!")
                                                .font(.system(size: 20))
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                } else {
                                    ScrollView {
                                        ForEach(Array(moneyManager.debts), id: \.id) { debt in
                                            HStack {
                                                Text(debt.description)
                                                Spacer()
                                                Text("\(debt.amount, specifier: "%.2f") EUR")
                                                    .foregroundColor(.red)
                                                Button(action: {
                                                    moneyManager.deleteDebt(debt, dateManager.currentMonth, dateManager.currentYear)
                                                }) {
                                                    Image(systemName: "creditcard.fill")
                                                }
                                           }
                                        }
                                    }.padding(.horizontal, 6)
                                }
                                Spacer()
                            }
                        }.padding(.leading)

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
                        
                        List(moneyManager.filteredTransactions, id: \.self) { transaction in
                            HStack {
                                Text("\(transaction.date, formatter: dateFormatter)")
                                Text("\(transaction.description)")
                                Spacer()
                                Text("- \(transaction.amount, specifier: "%.2f") EUR").foregroundColor(.red)
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
                                Button(action: {
                                    showingAddSheet.toggle()
                                }, label: {
                                    Image(systemName: "plus.circle.fill")
                                         .resizable()
                                         .aspectRatio(contentMode: .fit)
                                         .frame(width: 50, height: 50)
                                         .padding(.trailing, 15)
                                         .padding(.bottom)
                                }).padding(.trailing)
                            }
                        }

                     }
                }.tabItem {
                    Image(systemName: "house")
                }
                .background(backgroundColor)
            }
        }.sheet(isPresented: $showingAddSheet, content: {
            NavigationView {
                AddExpenseView(moneyManager: moneyManager, dateManager: dateManager)
            }
        })
        .sheet(isPresented: $showingFilterSheet, content: {
            NavigationView {
                FilterExpenseView(moneyManager: moneyManager, dateManager: dateManager)
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
