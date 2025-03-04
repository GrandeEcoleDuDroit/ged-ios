import Foundation

class CreateUserUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(user: User) async throws {
        try await userRepository.createUser(user: user)
    }
}
