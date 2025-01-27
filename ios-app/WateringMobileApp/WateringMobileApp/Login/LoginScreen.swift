import SwiftUI

struct LoginScreen: View {
    let userDefaultsManager = UserDefaultsManager()
    
    @State private var userName = ""
    @State private var deviceId = ""
    @State private var navigateToHome = false
    @State private var showError = false
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {

                Color.blue.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack(spacing: 32) {

                        VStack(spacing: 16) {
                            
                            Image(systemName: "drop.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(.linearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                            
                            VStack(spacing: 8) {
                                Text("Welcome to AquaSmart")
                                    .font(.title)
                                    .bold()
                                
                                Text("Please enter your credentials")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 60)
                        
                        VStack(spacing: 20) {
                            CustomTextField(
                                icon: "person",
                                placeholder: "Username",
                                text: $userName
                            )
                            
                            CustomTextField(
                                icon: "sprinkler.and.droplets.fill",
                                placeholder: "Device ID",
                                text: $deviceId
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Login Button
                        Button(action: handleLogin) {
                            HStack {
                                Text("Login")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: userName.isEmpty || deviceId.isEmpty ?
                                            [Color.gray, Color.gray] :
                                            [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 24)
                        .disabled(userName.isEmpty || deviceId.isEmpty)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeScreen()
            }
            .alert("Invalid Input", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter valid username and device ID")
            }
            .navigationBarBackButtonHidden()
        }
    }
    
    private func handleLogin() {
        guard !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !deviceId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError = true
            return
        }
        
        userDefaultsManager.saveUserCredentials(
            userName: userName.trimmingCharacters(in: .whitespacesAndNewlines),
            deviceId: deviceId.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        navigateToHome = true
    }
}

// Custom TextField Component
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .textContentType(placeholder == "Username" ? .username : .none)
                .autocapitalization(.none)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    LoginScreen()
}
