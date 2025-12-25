import Combine
import Foundation

protocol UserApi {
    func listenUser(userId: String) -> AnyPublisher<User?, Error>
    
    func getUsers() async throws -> [User]

    func getUser(userId: String) async throws -> User?
    
    func createUser(user: User) async throws
            
    func updateProfilePicture(user: User, imageData: Data, fileName: String) async throws
    
    func deleteUser(user: User) async throws
    
    func deleteProfilePicture(user: User) async throws
    
    func reportUser(report: UserReport) async throws
}
