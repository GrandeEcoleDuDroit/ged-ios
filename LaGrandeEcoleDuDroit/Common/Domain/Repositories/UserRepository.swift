import Combine

protocol UserRepository {
    var currentUser: CurrentValueSubject<User?, Never> { get }
    
    func createUser(user: User) async throws
    
    func getUser(userId: String) async -> User?
    
    func getUserWithEmail(email: String) async -> User?
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Never>
    
    func getUsers() async throws -> [User]
    
    func getFilteredUsers(filter: String) async -> [User]
    
    func setCurrentUser(user: User)
    
    func removeCurrentUser()
    
    func updateProfilePictureUrl(userId: String, profilePictureFileName: String) async throws
}
