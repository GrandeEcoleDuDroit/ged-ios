import Combine

protocol AuthenticationRepository {
    var isAuthenticated: CurrentValueSubject<Bool, Never> { get }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws
    
    func registerWithEmailAndPassword(email: String, password: String) async throws
    
    func logout() async
    
    func sendEmailVerification() async throws
    
    func isEmailVerified() async throws -> Bool
            
    func setAuthenticated(_ isAuthenticated: Bool) async
}
