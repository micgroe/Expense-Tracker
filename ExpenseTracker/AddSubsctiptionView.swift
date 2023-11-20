//
//  AddSubsctiptionView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 03.10.23.
//

import SwiftUI

struct AddSubscriptionView: View {
    private func convertCommaToPeriod(_ input: String) -> String {
        return input.replacingOccurrences(of: ",", with: ".")
    }
    
    var categories = [
        "House": "house.fill",
        "Travel": "airplane",
        "Grocery": "cart.fill",
        "Gaming": "gamecontroller.fill",
        "Car": "car.fill",
        "Restaurant": "fork.knife",
        "Sports": "figure.run",
        "Alcohol": "wineglass"
    ]
    let itemsPerRow = 4
    
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    
    @State private var amount = ""
    @State private var description = ""
    
    @State private var selectedItem: String? = nil
    @State private var selectedItemIcon: String? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Form {
                TextField("Enter Amount", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Description", text: $description)
                Section(header: Text("Category")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: itemsPerRow), spacing: 16)  {
                            ForEach(categories.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                            VStack {
                                Image(systemName: value)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                Text(key)
                                    .font(.system(size: 13))
                            }.frame(width: 55, height: 55)
                            .background(selectedItem == key ? Color.blue.opacity(0.7) : Color.clear)
                            .onTapGesture {
                                selectedItem = key
                                selectedItemIcon = value
                            }.cornerRadius(5)
                            .padding(5)
                        }
                    }
//                    Button("Customize categories") {
//
//                    }
                }
            }
            
        }
        .navigationBarItems(trailing: Button("Add") {
            if let addAmount = Double(convertCommaToPeriod(amount)) {
                moneyManager.addSubscription(subscription: Subscription(
                                                    amount: addAmount,
                                                    description: description, category: selectedItem ?? "Other",
                                                    icon: selectedItemIcon ?? "Other"))
                amount = ""
                presentationMode.wrappedValue.dismiss()
            }
        }.disabled(selectedItemIcon==nil))
    }
}

#Preview {
    AddSubscriptionView(moneyManager: MoneyManager(), dateManager: DateManager())
}
