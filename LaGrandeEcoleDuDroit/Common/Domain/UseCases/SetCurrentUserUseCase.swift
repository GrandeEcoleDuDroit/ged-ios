class SetCurrentUserUseCase {
    private let userLocalRepository: UserLocalRepository
    
    init(userLocalRepository: UserLocalRepository) {
        self.userLocalRepository = userLocalRepository
    }
    
    func execute(user: User) {
        userLocalRepository.setCurrentUser(user: user)
    }
}
