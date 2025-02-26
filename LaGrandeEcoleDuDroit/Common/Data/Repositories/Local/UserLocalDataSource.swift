import Combine
import Foundation

class UserLocalDataSource {
    private let userKey = "USER_KEY"
    private(set) var currentUser = CurrentValueSubject<User?, Never>(nil)
    
    init() {
        loadCurrentUser()
    }
    
    func setCurrentUser(user: User) {
        let localUser = UserMapper.toLocalUser(user: user)
        if let localUserJson = try? JSONEncoder().encode(localUser) {
            UserDefaults.standard.set(localUserJson, forKey: userKey)
            currentUser.send(user)
        }
    }
 
    func removeCurrentUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
        currentUser.send(nil)
    }
    
    private func loadCurrentUser() {
        guard let localUserData = UserDefaults.standard.data(forKey: userKey) else {
            currentUser.send(nil)
            return
        }
        
        if let localUser = try? JSONDecoder().decode(LocalUser.self, from: localUserData) {
            currentUser.send(UserMapper.toDomain(localUser: localUser))
        } else {
            currentUser.send(nil)
        }
    }
    
    func updateProfilePictureUrl(fileName: String) {
        guard let currentUser = currentUser.value else {
            return
        }
        
        let updatedUser = currentUser.with(profilePictureUrl: UserMapper.formatProfilePictureUrl(fileName: fileName))
        setCurrentUser(user: updatedUser)
    }
}
