import Combine
import Foundation

private let authenticationStateKey = "authenticationStateKey"

class AuthenticationLocalDataSource {
    func listenAuthenticationState() -> AnyPublisher<AuthenticationState, Never> {
        UserDefaults.standard.publisher(for: \.authenticationState)
            .map { [weak self] value in
                if let value {
                    self?.parseAuthenticationState(value) ?? .unauthenticated
                } else {
                    .unauthenticated
                }
            }
            .eraseToAnyPublisher()
    }
    
    func storeAuthenticationState(_ state: AuthenticationState) {
        guard let jsonString = parseAuthenticationStateToJson(state) else {
            return
        }
        UserDefaults.standard.authenticationState = jsonString
    }
    
    func getAuthenticationState() -> AuthenticationState? {
        guard let jsonValue = UserDefaults.standard.authenticationState else {
            return nil
        }
        return parseAuthenticationState(jsonValue)
    }
    
    private func parseAuthenticationState(_ value: String) -> AuthenticationState? {
        if let data = value.data(using: .utf8) {
            try? JSONDecoder().decode(AuthenticationState.self, from: data)
        } else {
            nil
        }
    }
    
    private func parseAuthenticationStateToJson(_ state: AuthenticationState) -> String? {
        if let data = try? JSONEncoder().encode(state) {
            String(data: data, encoding: .utf8)
        } else {
            nil
        }
    }
}

extension UserDefaults {
    @objc dynamic var authenticationState: String? {
        get { string(forKey: authenticationStateKey) }
        set { set(newValue, forKey: authenticationStateKey) }
    }
}
