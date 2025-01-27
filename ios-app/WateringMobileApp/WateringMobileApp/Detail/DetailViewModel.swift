import Foundation

@Observable final class DetailViewModel {
    private let apiCode = ""
    private let baseURL = ""
    
    var soilMoisture: Double
    var waterLevel: Double
    var deviceId: String
    var userId: String
    var id: String
    
    var isLoading = false
    var errorMessage: String?
    var isUpdateSuccessful = false
    
    init(deviceData: DeviceData, userId: String, deviceId: String, id: String) {
        self.soilMoisture = deviceData.soilMoisture
        self.waterLevel = deviceData.waterLevel
        self.userId = userId
        self.deviceId = deviceId
        self.id = id
    }
    
    func updateData() async {
        isLoading = true
        errorMessage = nil
        
        let urlString = "\(baseURL)/UpdateDeviceData?code=\(apiCode)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create form data
        var formData = Data()
        let formFields = [
            "id": id,
            "user_id": userId,
            "device_id": deviceId,
            "soil_moisture": String(soilMoisture),
            "water_level": String(waterLevel)
        ]
        
        // Add form fields
        for (key, value) in formFields {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            formData.append("\(value)\r\n".data(using: .utf8)!)
        }
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = formData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(UpdateResponse.self, from: data)
            isUpdateSuccessful = response.message == "Data updated successfully."
        } catch {
            print("Error updating data: \(error.localizedDescription)")
            errorMessage = "Error updating data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 
