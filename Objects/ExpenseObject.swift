//
//  ExpenseObject.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 19.12.23.
//

import Foundation
import RealmSwift

class Expense: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userID: String
    @Persisted var amount: Double
    @Persisted var date: Date
    @Persisted var category: String
    @Persisted var descriptions: String
    
    convenience init(userID: String, amount: Double, date: Date, category: String, descriptions: String) {
        self.init()
        self.userID = userID
        self.amount = amount
        self.date = date
        self.category = category
        self.descriptions = descriptions
    }
}
