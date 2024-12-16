class GetUsersUseCase {
    private let userRepository: UserRepository
    
   init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() async throws -> [User] {
        try await userRepository.getUsers()
    }
}
