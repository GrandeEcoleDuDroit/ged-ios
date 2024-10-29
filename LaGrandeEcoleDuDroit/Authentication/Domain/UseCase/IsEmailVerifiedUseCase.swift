class IsEmailVerifiedUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute(completion: @escaping (Bool) -> Void) {
        authenticationRemoteRepository.isEmailVerified { isVerified in
            completion(isVerified)
        }
    }
}
