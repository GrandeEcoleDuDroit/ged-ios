import Combine

class ListenRemoteUserUseCase {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    private var cancellables: Set<AnyCancellable> = []
    private let tag = String(describing: ListenRemoteUserUseCase.self)
    
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
                    .catch{ [weak self] error in
                        e(
                            self?.tag ?? "ListenRemoteUserUseCase",
                            "Failed to listen remote user: \(error.localizedDescription)",
                            error
                        )
                        return Empty<User?, Never>()
                    }
                    .compactMap { $0 }
                    .filter { $0  != user }
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
