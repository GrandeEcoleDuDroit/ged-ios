class GetUserUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func executeWithId(userId: String) async -> User? {
        await userRepository.getUser(userId: userId)
    }
    
    func executeWithEmail(email: String) async throws -> User? {
        try await userRepository.getUserWithEmail(email: email)
    }
}
