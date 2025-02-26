import Combine

class GetCurrentUserUseCase {
    private let userRepository: UserRepository
    
   init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() -> CurrentValueSubject<User?, Never> {
        userRepository.currentUser
    }
}
