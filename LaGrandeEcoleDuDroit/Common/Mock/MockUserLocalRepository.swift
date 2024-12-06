import Combine

class MockUserLocalRepository: UserLocalRepository {
    var currentUserPublisher: AnyPublisher<User?, Never> {
        Just(userFixture).eraseToAnyPublisher()
    }
    
    var currentUser: User? = userFixture
    
    func setCurrentUser(user: User) {
        currentUser = user
    }
    
    func removeCurrentUser() {
        currentUser = nil
    }    
}
