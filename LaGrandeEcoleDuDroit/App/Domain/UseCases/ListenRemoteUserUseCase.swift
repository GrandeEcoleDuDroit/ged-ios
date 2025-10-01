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
            .flatMap { user in
                self.userRepository.getUserPublisher(userId: user.id)
                    .filter { $0 != user }
                    .map(\.self)
                    .catch { error -> AnyPublisher<User?, Never> in
                        e(self.tag, "Error fetching user: \(error)", error)
                        return Empty(completeImmediately: true)
                            .eraseToAnyPublisher()
                    }
            }
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    e(
                        self?.tag ?? String(describing: ListenRemoteUserUseCase.self),
                        "Failed to listen remote user: \(error)",
                        error
                    )
                }
            }, receiveValue: { [weak self] user in
                if let user {
                    self?.userRepository.storeUser(user)
                } else {
                    self?.authenticationRepository.logout()
                }
            })
            .store(in: &cancellables)
    }

    func stop() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
