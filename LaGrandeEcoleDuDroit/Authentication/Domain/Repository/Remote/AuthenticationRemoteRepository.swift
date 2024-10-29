import Combine

protocol AuthenticationRemoteRepository {
    func register(email: String, password: String) -> AnyPublisher<Void, Error>
    
    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void)
    
    func isEmailVerified(completion: @escaping (Bool) -> Void)
}
