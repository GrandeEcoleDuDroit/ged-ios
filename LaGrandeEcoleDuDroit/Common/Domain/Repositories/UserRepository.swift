import Combine
import Foundation

protocol UserRepository {
    var user: AnyPublisher<User, Never> { get }
    
    var currentUser: User? { get }
    
    func getUsers() async -> [User]
    
    func getUserPublisher(userId: String) -> AnyPublisher<User?, Error>
    
    func getCurrentUser() -> User?
    
    func getUser(userId: String) async throws -> User?
    
    func storeUser(_ user: User)
    
    func createUser(user: User) async throws
    
    func updateProfilePicture(user: User, imageData: Data, fileName: String) async throws
    
    func deleteUser(user: User) async throws

    func deleteLocalUser()

    func deleteProfilePicture(user: User) async throws
    
    func reportUser(report: UserReport) async throws
}
