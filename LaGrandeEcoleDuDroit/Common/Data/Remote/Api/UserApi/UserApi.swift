import Combine

protocol UserApi {
    func listenUser(userId: String) -> AnyPublisher<User?, Error>
    
    func getUsers() async throws -> [User]

    func getUser(userId: String) async throws -> User?
    
    func createUser(user: User) async throws
        
    func updateUser(user: User) async throws
    
    func updateProfilePictureFileName(user: User, fileName: String) async throws
    
    func deleteProfilePictureFileName(user: User) async throws
    
    func reportUser(report: UserReport) async throws
}
