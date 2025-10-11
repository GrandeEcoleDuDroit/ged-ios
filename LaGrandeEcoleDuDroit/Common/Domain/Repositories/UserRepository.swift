import Combine

protocol UserRepository {
    var user: AnyPublisher<User, Never> { get }
    
    var currentUser: User? { get }
    
    func getCurrentUser() -> User?
    
    func createUser(user: User) async throws
    
    func getUser(userId: String) async throws -> User?
    
    func getUserWithEmail(email: String) async throws -> User?
    
    func getUserPublisher(userId: String) -> AnyPublisher<User?, Never>
    
    func getUsers() async -> [User]
        
    func storeUser(_ user: User)
    
    func deleteCurrentUser() async throws
    
    func deleteLocalCurrentUser()
    
    func updateProfilePictureFileName(userId: String, profilePictureFileName: String) async throws
    
    func deleteProfilePictureFileName(userId: String) async throws
    
    func reportUser(report: UserReport) async throws
}
