import Foundation

@Observable final class HomeViewModel {

    private let apiCode = ""
    private let baseURL = ""
    
    var deviceData: DeviceData?
    var isLoading = false
    var errorMessage: String?
    
    func getData() async {
        
        isLoading = true
        errorMessage = nil
        
        guard let userId = UserDefaultsManager.shared.userId,
              let deviceId = UserDefaultsManager.shared.deviceId else {
            errorMessage = "User or device information not found"
            isLoading = false
            return
        }
        
        let urlString = "\(baseURL)/GetDeviceData?user_id=\(userId)&device_id=\(deviceId)&code=\(apiCode)"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedDataArray = try JSONDecoder().decode([DeviceData].self, from: data)
            
            // Sort by timestamp and get the most recent item
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let sortedData = decodedDataArray.sorted { first, second in
                guard let firstTimestamp = first.timestamp,
                      let secondTimestamp = second.timestamp else {
                    return false // Move items without timestamps to the end
                }
                
                // Parse dates
                guard let firstDate = formatter.date(from: firstTimestamp),
                      let secondDate = formatter.date(from: secondTimestamp) else {
                    return false // Move items with invalid timestamps to the end
                }
                
                return firstDate > secondDate // Sort in descending order (most recent first)
            }
            
            // Get the most recent reading
            deviceData = sortedData.first
            
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            errorMessage = "Error fetching data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
