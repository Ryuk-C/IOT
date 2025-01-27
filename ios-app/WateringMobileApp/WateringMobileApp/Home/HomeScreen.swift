//
//  HomeScreen.swift
//  AquaSmart
//
//  Created by Cuma on 15/01/2025.
//

import SwiftUI

struct HomeScreen: View {

    @State private var shouldNavigateToLogin = false
    let model = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome, \(UserDefaultsManager.shared.userId ?? "User")")
                            .font(.title2)
                            .bold()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    if model.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            Spacer()
                    } else if let error = model.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if let deviceData = model.deviceData {
                        NavigationLink(destination: DetailScreen(deviceData: deviceData)) {
                            // Combined Sensor Data Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("\(UserDefaultsManager.shared.deviceId ?? "Unknown")")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 20) {
                                    // Soil Moisture
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "leaf.fill")
                                                .foregroundColor(.green)
                                            Text("Soil Moisture")
                                                .font(.subheadline)
                                        }
                                        Text("\(deviceData.soilMoisture, specifier: "%.1f")%")
                                            .font(.title2)
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    
                                    // Water Level
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "drop.fill")
                                                .foregroundColor(.blue)
                                            Text("Water Level")
                                                .font(.subheadline)
                                        }
                                        Text("\(deviceData.waterLevel, specifier: "%.1f")%")
                                            .font(.title2)
                                            .bold()
                                    }
                                }
                                
                                if let timestamp = deviceData.timestamp {
                                    Text("Last Updated: \(formatDate(timestamp))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding()
                        }
                        
                        Spacer()
                    }
                }
            }
            .refreshable {
                await model.getData()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: logout) {
                        Text("Exit")
                            .foregroundColor(.red)
                            .bold()
                    }
                }
            }
            .task {
                await model.getData()
            }
            .navigationDestination(isPresented: $shouldNavigateToLogin) {
                LoginScreen()
            }
        }
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else {
            return "Unknown"
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return "Unknown"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .medium
        return outputFormatter.string(from: date)
    }
    
    private func logout() {
        // Clear UserDefaults
        UserDefaultsManager.shared.clearAll()
        // Navigate to login screen
        shouldNavigateToLogin = true
    }
}

#Preview {
    HomeScreen()
}
