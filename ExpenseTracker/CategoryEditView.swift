//
//  CategoryEditView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 01.12.23.
//

import SwiftUI

struct CategoryEditView: View {
    @ObservedObject var categoryManager: CategoryManager
    
    @State var selectedCategory: String? = nil
    @State var addedLimit: String? = nil
    
    private let itemsPerRow = 4
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Form {
                if !categoryManager.categoryLimits.isEmpty {
                    Section(header: Text("Current Limits")) {
                        List {
                            ForEach(categoryManager.categoryLimits.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                                HStack {
                                    Text(key)
                                    Spacer()
                                    Text(String(format: "%.2f", value))
                                }
                            }.onDelete { index in
                                let keys = index.map { Array(categoryManager.categoryLimits.keys.sorted(by: { $0 < $1 }))[$0] }
                                for key in keys {
                                    categoryManager.removeCategoryLimit(category: key)
                                }
                            }
                        }
                    }
                }
                Section(header: Text("Add Limit")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: itemsPerRow), spacing: 16) {
                        ForEach(categoryManager.categoryIcons.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                            if !categoryManager.categoryLimits.keys.contains(key) {
                                VStack {
                                    VStack {
                                        Image(systemName: value)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                        Text(key)
                                            .font(.system(size: 13))
                                    }.frame(width: 55, height: 55)
                                }.frame(width: 75, height: 75)
                                .background(selectedCategory == key ? Color.blue.opacity(0.7) : Color.clear)
                                .onTapGesture {
                                    selectedCategory = key
                                }.cornerRadius(5)
                            }
                        }
                    }
                    HStack {
                        TextField("Enter limit", text: Binding(
                             get: { addedLimit ?? "" },
                             set: { addedLimit = $0 }
                         ))
                            .keyboardType(.decimalPad)
                        Spacer()
                        Button("Add") {
                            if let category = selectedCategory, let limit = addedLimit {
                                categoryManager.addCategoryLimit(category: category, limit: Double(limit)!)
                                selectedCategory = nil
                                addedLimit = nil
                            }
                        }.foregroundStyle(selectedCategory != nil && addedLimit != nil ? Color.blue : Color.gray)
                    }
                }
            }
        }.navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
    }
}

#Preview {
    CategoryEditView(categoryManager: CategoryManager())
}
