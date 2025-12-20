import Combine

protocol UserRepository {
    var user: AnyPublisher<User, Never> { get }
    
    var currentUser: User? { get }
    
    func getUsers() async -> [User]
    
    func getUserPublisher(userId: String, currentUser: User) -> AnyPublisher<User?, Error>
    
    func getCurrentUser() -> User?
    
    func getUser(userId: String, tester: Bool) async throws -> User?
    
    func storeUser(_ user: User)
    
    func createUser(user: User) async throws
    
    func updateRemoteUser(user: User) async throws
    
    func updateProfilePictureFileName(user: User, profilePictureFileName: String) async throws
    
    func deleteLocalUser()
        
    func deleteProfilePictureFileName(user: User) async throws
    
    func reportUser(report: UserReport) async throws
}
