import SwiftUI

struct DetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: DetailViewModel
    
    init(deviceData: DeviceData) {
        let userId = UserDefaultsManager.shared.userId ?? ""
        let deviceId = UserDefaultsManager.shared.deviceId ?? ""
        let id = "\(userId)-\(deviceId)-\(Int(Date().timeIntervalSince1970))"
        _model = State(initialValue: DetailViewModel(deviceData: deviceData, 
                                                   userId: userId, 
                                                   deviceId: deviceId, 
                                                   id: id))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Device Info Card
                    VStack(spacing: 12) {
                        Image(systemName: "sensor.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text(model.deviceId)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Soil Moisture Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            Text("Soil Moisture")
                                .font(.title3)
                                .bold()
                        }
                        
                        Text("\(model.soilMoisture, specifier: "%.1f")%")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.green)
                        
                        Slider(value: $model.soilMoisture, in: 0...100)
                            .tint(.green)
                    }
                    .padding(20)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Water Level Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Water Level")
                                .font(.title3)
                                .bold()
                        }
                        
                        Text("\(model.waterLevel, specifier: "%.1f")%")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Slider(value: $model.waterLevel, in: 0...100)
                            .tint(.blue)
                    }
                    .padding(20)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Update Button
                    Button(action: {
                        Task {
                            await model.updateData()
                        }
                    }) {
                        HStack(spacing: 12) {
                            if model.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Update Values")
                                    .bold()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .disabled(model.isLoading)
                    
                    if let error = model.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Sensor Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: model.isUpdateSuccessful) { success in
                if success {
                    dismiss()
                }
            }
        }
    }
} 