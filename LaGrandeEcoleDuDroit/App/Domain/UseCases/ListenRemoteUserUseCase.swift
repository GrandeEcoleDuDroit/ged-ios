import Combine

private let tag = String(describing: ListenRemoteUserUseCase.self)

class ListenRemoteUserUseCase {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository
    ) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
    }
    
    func start() {
        userRepository.user
            .removeDuplicates { old, new in
                old.id == new.id
            }
            .flatMap { [weak self] user in
                self?.userRepository.getUserPublisher(userId: user.id)
                    .catch{ error in
                        e(tag, "Failed to listen remote user \(user.fullName)", error)
                        return Empty<User?, Never>()
                    }
                    .compactMap { $0 }
                    .filter { $0 != user }
                    .eraseToAnyPublisher()
                ?? Empty().eraseToAnyPublisher()
            }
            .sink { [weak self] user in
                self?.userRepository.storeUser(user)
            }
            .store(in: &cancellables)
    }

    func stop() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
