//
//  TestManager.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 23.12.23.
//

import Foundation
import RealmSwift

class TestManager: ObservableObject {
    private var realm: Realm?
    
    init() {
    }
    
    private func setupRealm() {
        if let user = realmApp.currentUser {
            let config = user.flexibleSyncConfiguration()
            realm = try? Realm(configuration: config)
        }
    }
    
    private func subscribe() {
        let subscriptions = realm!.subscriptions
        if subscriptions.first(named: "Expenses") == nil {
            subscriptions.update {
                subscriptions.append(QuerySubscription<Expense>(name: "Expenses") {
                    $0.userID == (realmApp.currentUser?.id)!
                })
                
            }
        }
    }
    
    func addExpense(expense: Expense) {
        do {
            try realm?.write {
                realm!.add(expense)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
