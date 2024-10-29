class SendVerificationEmailUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute(completion: @escaping (Bool) -> Void) {
        authenticationRemoteRepository.sendEmailVerification { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
}
