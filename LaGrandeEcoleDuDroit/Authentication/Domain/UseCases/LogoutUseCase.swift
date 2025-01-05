import Foundation
import Combine

class LogoutUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute() throws {
        try authenticationRepository.logout()
    }
}
