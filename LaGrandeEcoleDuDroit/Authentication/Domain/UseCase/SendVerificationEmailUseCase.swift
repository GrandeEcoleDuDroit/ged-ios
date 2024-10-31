class SendVerificationEmailUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute(completion: @escaping (Result<Void, AuthenticationError>) -> Void) {
        return authenticationRemoteRepository.sendEmailVerification(completion: completion)
    }
}
