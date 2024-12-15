import Combine

class GetCurrentUserUseCase {
    private let userRepository: UserRepository
    
   init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() -> User? {
        return userRepository.currentUser
    }
    
    func executeWithPublisher() -> AnyPublisher<User?, Never> {
        return userRepository.currentUserPublisher
    }
}
