import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let userId = "userId"
        static let deviceId = "deviceId"
    }
    
    init() {}
    
    var isUserLoggedIn: Bool {
        userId != nil && deviceId != nil
    }
    
    var userId: String? {
        get { defaults.string(forKey: Keys.userId) }
        set { defaults.set(newValue, forKey: Keys.userId) }
    }
    
    var deviceId: String? {
        get { defaults.string(forKey: Keys.deviceId) }
        set { defaults.set(newValue, forKey: Keys.deviceId) }
    }
    
    func clearAll() {
        userId = nil
        deviceId = nil
    }
    
    func saveUserCredentials(userName: String, deviceId: String) {
        self.userId = userName
        self.deviceId = deviceId
    }
} 