import Foundation
import Combine

class MockUserRepository: UserRepository {
    var user: AnyPublisher<User, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    var currentUser: User? { nil }
    
    func getUsers() async -> [User] { [] }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User?, Error> {
        Empty().eraseToAnyPublisher()
    }
    
    func getCurrentUser() -> User? { nil }
    
    func getUser(userId: String) async -> User? { nil }
    
    func getUsers(currentUser: User) async -> [User] { [] }
    
    func storeUser(_ user: User) {}
    
    func createUser(user: User) async throws {}
    
    func updateProfilePicture(user: User, imageData: Data, fileName: String) async throws {}

    func deleteUser(user: User) async throws {}
        
    func deleteLocalUser() {}

    func deleteProfilePicture(user: User) async throws {}
    
    func reportUser(report: UserReport) async throws {}
}
