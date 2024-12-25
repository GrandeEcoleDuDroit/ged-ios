import Foundation
import Combine

class UserRepositoryImpl: UserRepository {
    private let userLocalDataSource: UserLocalDataSource
    private let userRemoteDataSource: UserRemoteDataSource
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var _currentUser: User?
    
    var currentUserPublisher: AnyPublisher<User?, Never> {
        $_currentUser.eraseToAnyPublisher()
    }
    
    var currentUser: User? {
        _currentUser
    }
    
    init(userLocalDataSource: UserLocalDataSource, userRemoteDataSource: UserRemoteDataSource) {
        self.userLocalDataSource = userLocalDataSource
        self.userRemoteDataSource = userRemoteDataSource
        userLocalDataSource.currentUser.sink { [weak self] user in
            self?._currentUser = user
        }.store(in: &cancellables)
    }
    
    func createUser(user: User) async throws {
        try await userRemoteDataSource.createUser(user: user)
        userLocalDataSource.setCurrentUser(user: user)
    }
    
    func getUser(userId: String) async -> User? {
        await userRemoteDataSource.getUser(userId: userId)
    }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Never> {
        userRemoteDataSource.listenUser(userId: userId)
    }
    
    func getUsers() async throws -> [User] {
        try await userRemoteDataSource.getUsers()
    }
    
    func getFilteredUsers(filter: String) async -> [User] {
        await userRemoteDataSource.getFilteredUsers(filter: filter)
    }
        
    
    func setCurrentUser(user: User) {
        userLocalDataSource.setCurrentUser(user: user)
    }
    
    func removeCurrentUser() {
        userLocalDataSource.removeCurrentUser()
    }
}
