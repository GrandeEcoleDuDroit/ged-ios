class GetUserUseCase {
    private let userRepository: UserRepository
    
   init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(userId: String) async -> User? {
        do {
            return try await userRepository.getUser(userId: userId)
        } catch {
            return nil
        }
    }
}
