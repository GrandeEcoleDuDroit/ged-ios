import Combine

protocol UserApi {
    func listenUser(userId: String, currentUser: User) -> AnyPublisher<User?, Error>
    
    func getUsers() async throws -> [User]

    func getUser(userId: String, tester: Bool) async throws -> User?
    
    func createUser(user: User) async throws
        
    func updateUser(user: User) async throws
    
    func updateProfilePictureFileName(user: User, fileName: String) async throws
    
    func deleteProfilePictureFileName(user: User) async throws
    
    func reportUser(report: UserReport) async throws
}
