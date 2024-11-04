import Foundation

class UserLocalRepositoryImpl: UserLocalRepository, ObservableObject {
    private let userKey = "USER_KEY"
    
    @Published var currentUser: User? {
        didSet {
            saveCurrentUser()
        }
    }
    
    init() {
        loadCurrentUser()
    }
    
    func setCurrentUser(user: User) {
        currentUser = user
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func removeCurrentUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
        currentUser = nil
    }
    
    private func loadCurrentUser() {
        if let userLocalData = UserDefaults.standard.data(forKey: userKey) {
            do {
                let userLocal = try JSONDecoder().decode(UserLocal.self, from: userLocalData)
                currentUser = UserMapper.toDomain(userLocal: userLocal)
            } catch {
                print("Failed to decode user: \(error)")
                currentUser = nil
            }
        } else {
            currentUser = nil
        }
    }
    
    private func saveCurrentUser() {
        guard let user = currentUser else {
            return
        }
        
        let userLocal = UserMapper.toUserLocal(user: user)
        if let userLocalJson = try? JSONEncoder().encode(userLocal) {
            UserDefaults.standard.set(userLocalJson, forKey: userKey)
        }
    }
}
