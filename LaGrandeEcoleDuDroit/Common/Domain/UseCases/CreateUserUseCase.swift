class CreateUserUseCase {
    private let userRemoteRepository: UserRemoteRepository
    private let userLocalRepository: UserLocalRepository
    
    init(userRemoteRepository: UserRemoteRepository, userLocalRepository: UserLocalRepository) {
        self.userRemoteRepository = userRemoteRepository
        self.userLocalRepository = userLocalRepository
    }
    
    func execute(user: User) async throws {
        try await userRemoteRepository.createUser(user: user)
        userLocalRepository.setCurrentUser(user: user)
    }
}
