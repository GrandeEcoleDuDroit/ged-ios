import Foundation
import Combine

class MockUserRepository: UserRepository {
    private var users = usersFixture
    var currentUser = CurrentValueSubject<User?, Never>(userFixture)
    
    func setCurrentUser(user: User) {
        currentUser.send(user)
    }
    
    func removeCurrentUser() {
        currentUser.send(nil)
    }
    
    func createUser(user: User) async throws {
        users.append(user)
    }
    
    func getUser(userId: String) async -> User? {
        users.first { $0.id == userId }
    }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Never> {
        Just(users.first { $0.id == userId }!).eraseToAnyPublisher()
    }
    
    func getUsers() async throws -> [User] {
        users
    }
    
    func getFilteredUsers(filter: String) async -> [User] {
        usersFixture.filter { $0.fullName.contains(filter) }
    }
}
