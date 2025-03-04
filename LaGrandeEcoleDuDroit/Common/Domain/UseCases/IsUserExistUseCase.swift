class IsUserExistUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(email: String) async throws -> Bool {
        try await userRepository.getUserWithEmail(email: email) != nil
    }
}
