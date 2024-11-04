class SetCurretUserUseCase {
    private let userLocalRepository: UserLocalRepository = UserLocalRepositoryImpl()
    
    func execute(user: User) {
        userLocalRepository.setCurrentUser(user: user)
    }
}
