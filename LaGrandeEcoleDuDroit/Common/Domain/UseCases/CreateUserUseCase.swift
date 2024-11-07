import Foundation

class CreateUserUseCase {
    private let userRemoteRepository: UserRemoteRepository
    private let userLocalRepository: UserLocalRepository
    
    init(userRemoteRepository: UserRemoteRepository, userLocalRepository: UserLocalRepository) {
        self.userRemoteRepository = userRemoteRepository
        self.userLocalRepository = userLocalRepository
    }
    
    func execute(user: User) async throws {
        do {
            try await userRemoteRepository.createUser(user: user)
            userLocalRepository.setCurrentUser(user: user)
        } catch {
            if let error = error as? URLError {
                switch error.code {
                case .notConnectedToInternet:
                    throw NetworkError.notConnectedToInternet
                case .timedOut:
                    throw NetworkError.timedOut
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
    }
}
