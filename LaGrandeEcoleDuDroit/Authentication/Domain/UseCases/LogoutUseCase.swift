import Foundation
import Combine

class LogoutUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository
    
    init(authenticationRemoteRepository: AuthenticationRemoteRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute() throws {
        try authenticationRemoteRepository.logout()
    }
}
