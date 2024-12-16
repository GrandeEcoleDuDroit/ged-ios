import Combine

protocol UserRepository {
    var currentUserPublisher: AnyPublisher<User?, Never> { get }
    
    var currentUser: User? { get }
    
    func createUser(user: User) async throws
    
    func getUser(userId: String) async -> User?
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Never>
    
    func getUsers() async throws -> [User]
    
    func setCurrentUser(user: User)
    
    func removeCurrentUser()
}
