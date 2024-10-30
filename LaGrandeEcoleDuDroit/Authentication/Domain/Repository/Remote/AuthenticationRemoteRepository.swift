import Combine

protocol AuthenticationRemoteRepository {
    func register(email: String, password: String, completion: @escaping (Result<Void, AuthenticationError>) -> Void)
    
    func sendEmailVerification(completion: @escaping (Result<Void, AuthenticationError>) -> Void)
    
    func isEmailVerified(completion: @escaping (Bool) -> Void)
    
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthenticationError>) -> Void)
}
