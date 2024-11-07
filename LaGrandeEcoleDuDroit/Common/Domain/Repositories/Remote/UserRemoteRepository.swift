import Foundation

protocol UserRemoteRepository {
    func createUser(user: User) async throws
    
    func getUser(userId: String) async throws -> User?    
}
