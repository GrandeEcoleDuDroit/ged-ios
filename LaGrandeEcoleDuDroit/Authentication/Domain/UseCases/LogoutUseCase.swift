import Foundation
import Combine

class LogoutUseCase {
    private let authenticationRemoteRepository: AuthenticationRepository
    
    init(authenticationRemoteRepository: AuthenticationRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute() throws {
        try authenticationRemoteRepository.logout()
    }
}
