import Foundation
import Combine

class MockUserRepository: UserRepository {
    var user: AnyPublisher<User, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    var currentUser: User? { nil }
    
    func getCurrentUser() -> User? { nil }
        
    func getUser(userId: String) async -> User? { nil }
    
    func getUserWithEmail(email: String) async -> User? { nil }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User?, Error> {
        Empty().eraseToAnyPublisher()
    }
    
    func getUsers() async -> [User] { [] }
    
    func getFilteredUsers(filter: String) async -> [User] { [] }
    
    func storeUser(_ user: User) {}
    
    func createUser(user: User) async throws {}
    
    func updateRemoteUser(user: User) async throws {}
    
    func updateProfilePictureFileName(userId: String, profilePictureFileName: String) async throws {}
        
    func deleteLocalUser() {}
    
    func deleteProfilePictureFileName(userId: String) async throws {}
    
    func reportUser(report: UserReport) async throws {}
}
