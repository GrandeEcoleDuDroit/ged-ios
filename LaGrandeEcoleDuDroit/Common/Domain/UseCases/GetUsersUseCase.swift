class GetUsersUseCase {
    private let userRemoteRepository: UserRemoteRepository
    
    init(userRemoteRepository: UserRemoteRepository) {
        self.userRemoteRepository = userRemoteRepository
    }
    
    func execute() async throws -> [User] {
        try await userRemoteRepository.getUsers()
    }
}
