import Combine

class GetCurrentUserUseCase {
    private let userLocalRepository: UserLocalRepository
    
    init(userLocalRepository: UserLocalRepository) {
        self.userLocalRepository = userLocalRepository
    }
    
    func execute() -> AnyPublisher<User?, Never> {
        return userLocalRepository.currentUser
    }
}
