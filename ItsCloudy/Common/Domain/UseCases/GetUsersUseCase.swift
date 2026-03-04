class GetUsersUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() async -> [User] {
        let users = try? await userRepository.getUsers().filter {
            $0.state != .deleted
        }
        return users ?? []
    }
}
