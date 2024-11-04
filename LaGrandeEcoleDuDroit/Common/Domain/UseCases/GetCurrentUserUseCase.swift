class  GetCurrentUserUseCase {
    private let userLocalRepository: UserLocalRepository = UserLocalRepositoryImpl()
    
    func execute() -> User? {
        return userLocalRepository.getCurrentUser()
    }
}
