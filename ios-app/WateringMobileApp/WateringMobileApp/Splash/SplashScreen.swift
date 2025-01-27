//
//  SplashScreen.swift
//  AquaSmart
//
//  Created by Cuma on 15/01/2025.
//

import SwiftUI

struct SplashScreen: View {
    
    let userDefaultsManager = UserDefaultsManager()
    @State private var isActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("AquaSmart")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .navigationDestination(isPresented: $isActive) {
                if userDefaultsManager.isUserLoggedIn {
                    HomeScreen()
                } else {
                    LoginScreen()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isActive = true
            }
        }
    }
}

#Preview {
    SplashScreen()
}
