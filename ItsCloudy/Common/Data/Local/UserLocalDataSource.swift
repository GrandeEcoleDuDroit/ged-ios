import Combine
import Foundation

class UserLocalDataSource {
    private let userKey = "USER_KEY"
    
    func getUser() -> User? {
        guard let localUserData = UserDefaults.standard.data(forKey: userKey) else {
            return nil
        }
        
        let localUser = try? JSONDecoder().decode(LocalUser.self, from: localUserData)
        return localUser?.toUser()
    }
    
    func storeUser(user: User) throws {
        let localUserJson = try JSONEncoder().encode(user.toLocal())
        UserDefaults.standard.set(localUserJson, forKey: userKey)
    }
    
    func updateProfilePictureFileName(fileName: String?) throws {
        guard let localUserData = UserDefaults.standard.data(forKey: userKey) else {
            throw NSError()
        }
        let localUser = try JSONDecoder().decode(LocalUser.self, from: localUserData)
        var user = localUser.toUser()
        user.profilePictureUrl = UserUtils.ProfilePicture.getUrl(fileName: fileName)
        try storeUser(user: user)
    }
    
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}
