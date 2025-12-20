import Foundation
import Combine

class MockUserRepository: UserRepository {
    var user: AnyPublisher<User, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    var currentUser: User? { nil }
    
    func getUsers() async -> [User] { [] }
    
    func getUserPublisher(userId: String, currentUser: User) -> AnyPublisher<User?, Error> {
        Empty().eraseToAnyPublisher()
    }
    
    func getCurrentUser() -> User? { nil }
    
    func getUser(userId: String, tester: Bool) async -> User? { nil }
    
    func getUsers(currentUser: User) async -> [User] { [] }
    
    func storeUser(_ user: User) {}
    
    func createUser(user: User) async throws {}
    
    func updateRemoteUser(user: User) async throws {}
    
    func updateProfilePictureFileName(user: User, profilePictureFileName: String) async throws {}
        
    func deleteLocalUser() {}
    
    func deleteProfilePictureFileName(user: User) async throws {}
    
    func reportUser(report: UserReport) async throws {}
}
