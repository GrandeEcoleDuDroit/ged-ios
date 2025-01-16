import Foundation

class CreateUserUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(user: User) async throws {
        do {
            try await userRepository.createUser(user: user)
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
