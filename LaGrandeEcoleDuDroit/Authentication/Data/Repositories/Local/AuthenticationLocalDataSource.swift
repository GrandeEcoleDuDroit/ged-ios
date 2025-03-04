import Combine
import Foundation

class AuthenticationLocalDataSource {
    private let authenticationKey = "authenticationKey"
    private(set) var isAuthenticated = CurrentValueSubject<Bool, Never>(false)
    
    init() {
        Task {
            isAuthenticated.send(await getAuthenticatedState())
        }
    }
    
    func setAuthenticated(_ value: Bool) async {
        UserDefaults.standard.set(value, forKey: authenticationKey)
        isAuthenticated.send(value)
    }
    
    private func getAuthenticatedState() async -> Bool {
        UserDefaults.standard.bool(forKey: authenticationKey)
    }
}
