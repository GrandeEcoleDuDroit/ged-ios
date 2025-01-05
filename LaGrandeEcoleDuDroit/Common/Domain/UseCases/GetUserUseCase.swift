class GetUserUseCase {
    private let userRepository: UserRepository
    
   init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(userId: String) async -> User? {
        await userRepository.getUser(userId: userId)
    }
}
