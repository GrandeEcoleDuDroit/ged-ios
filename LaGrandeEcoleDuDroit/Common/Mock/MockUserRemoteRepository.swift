
class MockUserRemoteRepository: UserRemoteRepository {
    private var _users: [User] = usersFixture
    
    func createUser(user: User) async throws {
        _users.append(user)
    }
    
    func getUser(userId: String) async throws -> User? {
        userFixture
    }
    
    func getUsers() async throws -> [User] {
        _users
    }
}
