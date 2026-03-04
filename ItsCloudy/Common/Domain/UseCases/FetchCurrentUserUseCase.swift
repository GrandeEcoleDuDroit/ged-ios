class FetchCurrentUserUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(userId: String) async throws {
        if let user = try await userRepository.getUser(userId: userId) {
            userRepository.storeUser(user)
        }
    }
}
