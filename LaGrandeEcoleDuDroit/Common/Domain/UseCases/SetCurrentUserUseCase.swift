class SetCurrentUserUseCase {
    private let userRepository: UserRepository
    
   init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(user: User) {
        userRepository.setCurrentUser(user: user)
    }
}
