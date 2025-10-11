import Combine

protocol UserApi {
    func listenUser(userId: String) -> AnyPublisher<User?, Never>

    func getUser(userId: String) async throws -> User?
    
    func getUserWithEmail(email: String) async throws -> User?
        
    func getUsers() async throws -> [User]
    
    func createUser(user: User) async throws
        
    func updateProfilePictureFileName(userId: String, fileName: String) async throws
    
    func deleteUser(userId: String) async throws
    
    func deleteProfilePictureFileName(userId: String) async throws
    
    func reportUser(report: UserReport) async throws
}
