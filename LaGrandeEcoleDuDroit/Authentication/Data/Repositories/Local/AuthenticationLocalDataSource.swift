import Combine
import Foundation

class AuthenticationLocalDataSource {
    private let authenticationKey = "authenticationKey"
    
    func setAuthenticated(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: authenticationKey)
    }
    
    func isAuthenticated() -> Bool {
        UserDefaults.standard.bool(forKey: authenticationKey)
    }
}
