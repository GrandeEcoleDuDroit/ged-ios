class GetFilteredUsersUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(filter: String) async -> [User] {
        await userRepository.getFilteredUsers(filter: filter)
    }
}
