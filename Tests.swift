//
//  Tests.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 20.09.23.
//

import SwiftUI

struct Tests: View {
    @State private var isPickerVisible = false
    @State private var selectedOption: String? = "All Time"
    let options = ["All Time", "Today and Yesterday", "Today", "Last Hour"]

    var body: some View {
        Menu {
            Button(action: {
                                
            }) {
                Text("Expense")
                }
                Button(action: {
                    
                }) {
                    Text("Income")
                }
                Button(action: {
                    
                }) {
                    Text("Debt")
                }
            } label: {
                Image(systemName: "plus.circle.fill")
            }
        }
}


struct Tests_Previews: PreviewProvider {
    static var previews: some View {
        Tests()
    }
}
