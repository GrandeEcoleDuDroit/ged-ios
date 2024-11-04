class CreateUserUseCase {
    private let userRemoteRepository: UserRemoteRepository = UserRemoteRepositoryImpl()
    private let userLocalRepository: UserLocalRepository = UserLocalRepositoryImpl()
    
    func execute(user: User) async throws {
        try await userRemoteRepository.createUser(user: user)
        userLocalRepository.setCurrentUser(user: user)
    }
}
