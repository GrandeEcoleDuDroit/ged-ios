class CreateUserUseCase {
    private let userRemoteRepository: UserRemoteRepository = UserRemoteRepositoryImpl()
    
    func execute(user: User) async throws {
        try await userRemoteRepository.createUser(user: user)
    }
}
