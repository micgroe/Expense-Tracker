//
//  CategoryManagerClass.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 30.11.23.
//

import Foundation
import SwiftUI

class CategoryManager: ObservableObject {
    let categories: [String] = ["House", "Travel", "Grocery", "Gaming", "Car", "Restaurant", "Sports", "Alcohol"]
    
    let categoryIcons: [String: String] = [
        "House": "house.fill",
        "Travel": "airplane",
        "Grocery": "cart.fill",
        "Gaming": "gamecontroller.fill",
        "Car": "car.fill",
        "Restaurant": "fork.knife",
        "Sports": "figure.run",
        "Alcohol": "wineglass"
    ]
    
    @Published var categorySums: [String: Double] = [:]
    @Published var categoryLimits: [String: Double] = [:]
    
    init() {
        loadCategorySums()
        loadCategoryLimits()
    }
    
    func addCategorySum(name: String, amount: Double) {
        categorySums[name, default: 0] += amount
        saveCategorySums()
    }
    
    func calcLimitPercentage(category: String, limit: Double) -> Double {
        if let currentAmount = categorySums[category] {
            let percentage = currentAmount / limit
            return percentage
        }
        return 0
    }
    
    func addCategoryLimit(category: String, limit: Double) {
        categoryLimits[category] = limit
        saveCategoryLimits()
    }
    
    func removeCategoryLimit(category: String) {
        categoryLimits.removeValue(forKey: category)
        saveCategoryLimits()
    }
    
    func getRemainingLimit(maxLimit: Double, currentLimit: Double) -> Double {
        let remainingLimit = maxLimit - currentLimit
        return remainingLimit
    }
    
    func getLineColor(currentLimit: Double, category: String) -> Color {
        let percentage = currentLimit / categoryLimits[category]!
        if percentage <= 0.33 {
            return Color.orange
        } else if percentage > 0.33 && percentage <= 0.67 {
            return Color.yellow
        } else if percentage > 0.67 && percentage < 1 {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    private func loadCategorySums() {
        if let savedCategoryData = UserDefaults.standard.data(forKey: "CategorySums"),
           let savedCategories = try? JSONDecoder().decode([String: Double].self, from: savedCategoryData) {
                categorySums = savedCategories
        }
    }
    
    private func saveCategorySums() {
        if let encodedCategorySums = try? JSONEncoder().encode(categorySums) {
            UserDefaults.standard.set(encodedCategorySums, forKey: "CategorySums")
        }
    }
    
    private func loadCategoryLimits() {
        if let savedCategoryLimitData = UserDefaults.standard.data(forKey: "CategoryLimits"),
           let savedCategoryLimits = try? JSONDecoder().decode([String: Double].self, from: savedCategoryLimitData) {
            categoryLimits = savedCategoryLimits
        }
    }
    
    private func saveCategoryLimits() {
        if let encodedCategoryLimits = try? JSONEncoder().encode(categoryLimits) {
            UserDefaults.standard.set(encodedCategoryLimits, forKey: "CategoryLimits")
        }
    }
    
    func getCategoryBar(maxLimits: [String: Double], currentLimits: [String: Double]) -> [CategoryBar] {
        var categoryBars: [CategoryBar] = []
        
        for (category, maxLimit) in maxLimits {
            if let currentLimit = currentLimits[category] {
                let categoryBar = CategoryBar(maxLimit: maxLimit, currentLimit: currentLimit, category: category)
                categoryBars.append(categoryBar)
            }
        }
        return categoryBars
    }
    
    func limitIsExceeded(maxLimit: Double, currentLimit: Double) -> Bool {
        if currentLimit - maxLimit < 0 {
            return true
        } else {
            return false
        }
    }
    
}

struct CategoryBar: Identifiable {
    let id = UUID()
    let maxLimit: Double
    let currentLimit: Double
    let category: String
}
