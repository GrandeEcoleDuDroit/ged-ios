import Combine

class GetCurrentUserUseCase {
    private let userLocalRepository: UserLocalRepository
    
    init(userLocalRepository: UserLocalRepository) {
        self.userLocalRepository = userLocalRepository
    }
    
    func execute() -> User? {
        return userLocalRepository.currentUser
    }
    
    func executeWithPublisher() -> AnyPublisher<User?, Never> {
        return userLocalRepository.currentUserPublisher
    }
}
