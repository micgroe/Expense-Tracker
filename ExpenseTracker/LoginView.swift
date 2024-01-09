//
//  LoginView.swift
//  ExpenseTracker
//
//  Created by Michael Gröchenig on 26.12.23.
//

import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    
    var body: some View {
        VStack {
            if username == "" {
                ProgressView()
            } else {
                ContentView(username: username)
            }
        }
        .onAppear {
            login()
        }
    }

    
    private func login() {
        Task {
            do {
                let user = try await realmApp.login(credentials: .anonymous)
                username = user.id
                print(user.id)
            } catch {
                print("Error")
            }
        }
    }
}

#Preview {
    LoginView()
}
