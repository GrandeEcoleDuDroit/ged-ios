import Combine

protocol UserRepository {
    var user: AnyPublisher<User, Never> { get }
    
    var currentUser: User? { get }
    
    func createUser(user: User) async throws
    
    func getUser(userId: String) async throws -> User?
    
    func getUserWithEmail(email: String) async throws -> User?
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Error>
    
    func getUsers() async -> [User]
        
    func storeUser(_ user: User)
    
    func deleteCurrentUser()
    
    func updateProfilePictureFileName(userId: String, profilePictureFileName: String) async throws
}
