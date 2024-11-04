import Combine
import Foundation

class UserLocalRepositoryImpl: UserLocalRepository {
    private let userKey = "USER_KEY"
    
    @Published private var _currentUser: User?
    var currentUser: AnyPublisher<User?, Never> {
        return $_currentUser.eraseToAnyPublisher()
    }
    
    init() {
        loadCurrentUser()
    }
    
    func setCurrentUser(user: User) {
        let userLocal = UserMapper.toUserLocal(user: user)
        if let userLocalJson = try? JSONEncoder().encode(userLocal) {
            UserDefaults.standard.set(userLocalJson, forKey: userKey)
            _currentUser = user
        }
    }
 
    func removeCurrentUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
        _currentUser = nil
    }
    
    private func loadCurrentUser() {
        guard let userLocalData = UserDefaults.standard.data(forKey: userKey) else {
            _currentUser = nil
            return
        }
        
        if let userLocal = try? JSONDecoder().decode(UserLocal.self, from: userLocalData) {
            _currentUser = UserMapper.toDomain(userLocal: userLocal)
        } else {
            _currentUser = nil
        }
    }
}
