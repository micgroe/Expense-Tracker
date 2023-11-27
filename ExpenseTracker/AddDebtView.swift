//
//  AddDebtView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 15.11.23.
//

import SwiftUI

struct AddDebtView: View {
    private func convertCommaToPeriod(_ input: String) -> String {
        return input.replacingOccurrences(of: ",", with: ".")
    }
    
    @ObservedObject var moneyManager: MoneyManager
    @ObservedObject var dateManager: DateManager
    @ObservedObject var debtManager: DebtManager
    
    @State private var amount = ""
    @State private var description = ""
    @State private var date = Date()
    
    @State private var selectedItem: String? = nil
    @State private var selectedItemIcon: String? = nil
    
    @State var isEditing = false
    @State private var newDebitor: String = ""
    @State private var selectedDebitor: String = ""
    
    @State private var selectedIdx: Int? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
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
    
    var body: some View {
        ZStack {
            Form {
                TextField("Enter Amount", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Description", text: $description)
                DatePicker("Date of Debt", selection: $date, displayedComponents: .date)
                Section(header: Text("Debitor")) {
                    ForEach(debtManager.debitors.indices, id: \.self) { index in
                        SelectionRowView(
                            text: debtManager.debitors[index].name,
                            isSelected: selectedIdx == index,
                            onTap: {
                                selectedIdx = (selectedIdx == index) ? nil : index
                                selectedDebitor = debtManager.debitors[selectedIdx!].name
                            }
                        )
                    }
                    if isEditing {
                        TextField("New debitor", text: $newDebitor)
                    } else {
                        Button("New debitor") {
                            isEditing.toggle()
                        }
                    }
                }
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
                }
            }
        }.navigationTitle("Add Debt")
        .navigationBarItems(
            leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Add") {
                if !newDebitor.isEmpty {
                    selectedDebitor = newDebitor
                    debtManager.addDebitor(name: newDebitor)
                }
                debtManager.addDebt(name: selectedDebitor, transaction: Transaction(
                    amount: Double(convertCommaToPeriod(amount))!,
                    date: date,
                    category: selectedItem ?? "Other",
                    description: description,
                    icon: selectedItemIcon ?? "Other",
                    type: "Debt"))
                
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}

struct SelectionRowView: View {
    var text: String
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack {
                Image(systemName: isSelected ? "circle.dashed.inset.filled" : "circle.dashed")
                Text(text)
                    .foregroundStyle(.white)
                Spacer()
            }
        }
    }
}

#Preview {
    AddDebtView(moneyManager: MoneyManager(), dateManager: DateManager(), debtManager: DebtManager())
}
