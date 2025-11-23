class GetUsersUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() async -> [User] {
        await userRepository.getUsers().filter {
            $0.state != .deleted
        }
    }
}
