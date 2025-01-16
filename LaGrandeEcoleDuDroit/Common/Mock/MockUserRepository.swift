import Foundation
import Combine

class MockUserRepository: UserRepository {
    var currentUserPublisher = CurrentValueSubject<User?, Never>(userFixture).eraseToAnyPublisher()
    var currentUser: User? = userFixture
    
    func setCurrentUser(user: User) {
        currentUserPublisher = Just(user).eraseToAnyPublisher()
    }
    
    func removeCurrentUser() {
        currentUserPublisher = Just(nil).eraseToAnyPublisher()
    }
    
    func createUser(user: User) async throws {
        // No implementation needed
    }
    
    func getUser(userId: String) async -> User? {
        userFixture
    }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Never> {
        Just(userFixture).eraseToAnyPublisher()
    }
    
    func getUsers() async throws -> [User] {
        usersFixture
    }
    
    func getFilteredUsers(filter: String) async -> [User] {
        usersFixture.filter { $0.fullName.contains(filter) }
    }
}
