import Foundation
import Combine

class MockUserRepository: UserRepository {
    
    private var _users: [User] = usersFixture
    @Published private var _currentUser: User? = userFixture
    var currentUserPublisher: AnyPublisher<User?, Never> {
        $_currentUser.eraseToAnyPublisher()
    }
    var currentUser: User? {
        _currentUser
    }
    
    func setCurrentUser(user: User) {
        _currentUser = user
    }
    
    func removeCurrentUser() {
        _currentUser = nil
    }
    
    func createUser(user: User) async throws {
        _users.append(user)
    }
    
    func getUser(userId: String) async -> User? {
        userFixture
    }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Never> {
        Just(userFixture).eraseToAnyPublisher()
    }
    
    func getUsers() async throws -> [User] {
        var users = _users
        users.append(contentsOf: _users)
        return users
    }
    
    func getFilteredUsers(filter: String) async -> [User] {
        _users.filter { $0.fullName.contains(filter) }
    }
}
