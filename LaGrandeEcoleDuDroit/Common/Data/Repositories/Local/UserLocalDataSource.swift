import Combine
import Foundation

class UserLocalDataSource {
    private let userKey = "USER_KEY"
    @Published private var _currentUser: User?
    var currentUser: AnyPublisher<User?, Never> {
        $_currentUser.eraseToAnyPublisher()
    }
    
    init() {
        loadCurrentUser()
    }
    
    func setCurrentUser(user: User) {
        let localUser = UserMapper.toLocalUser(user: user)
        if let localUserJson = try? JSONEncoder().encode(localUser) {
            UserDefaults.standard.set(localUserJson, forKey: userKey)
            _currentUser = user
        }
    }
 
    func removeCurrentUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
        _currentUser = nil
    }
    
    private func loadCurrentUser() {
        guard let localUserData = UserDefaults.standard.data(forKey: userKey) else {
            _currentUser = nil
            return
        }
        
        if let localUser = try? JSONDecoder().decode(LocalUser.self, from: localUserData) {
            _currentUser = UserMapper.toDomain(localUser: localUser)
        } else {
            _currentUser = nil
        }
    }
}
