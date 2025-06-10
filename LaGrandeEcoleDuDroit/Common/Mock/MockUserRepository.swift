import Foundation
import Combine

class MockUserRepository: UserRepository {
    private var users = usersFixture
    private let userSubject = CurrentValueSubject<User?, Never>(userFixture)
    
    var user: AnyPublisher<User, Never> {
        userSubject.compactMap{$0}.eraseToAnyPublisher()
    }
    
    var currentUser: User? {
        userSubject.value
    }
    
    func storeUser(_ user: User) {}
    
    func deleteCurrentUser() {
        userSubject.send(nil)
    }
    
    func createUser(user: User) async throws {
        users.append(user)
    }
    
    func getUser(userId: String) async -> User? {
        users.first { $0.id == userId }
    }
    
    func getUserWithEmail(email: String) async -> User? {
        usersFixture.first { $0.email == email }
    }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Error> {
        Just(users.first { $0.id == userId }!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getUsers() async -> [User] {
        users
    }
    
    func getFilteredUsers(filter: String) async -> [User] {
        usersFixture.filter { $0.fullName.contains(filter) }
    }
    
    func updateProfilePictureFileName(userId: String, profilePictureFileName: String) async throws {
        userSubject.value = userSubject.value?.with(
            profilePictureUrl: UrlUtils.formatProfilePictureUrl(fileName: profilePictureFileName)
        )
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        userSubject.value = userSubject.value?.with(profilePictureUrl: nil)
    }
}
