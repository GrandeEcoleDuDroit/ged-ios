import Combine

protocol AuthenticationRemoteRepository {
    func register(email: String, password: String) async throws -> String
    
    func sendEmailVerification() async throws
    
    func isEmailVerified() async throws -> Bool
    
    func login(email: String, password: String) async throws -> String
}
