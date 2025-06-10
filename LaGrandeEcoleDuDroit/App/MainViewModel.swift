import Combine
import Foundation

private let tag = String(describing: MainViewModel.self)

class MainViewModel: ObservableObject {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    private let listenDataUseCase: ListenDataUseCase
    private let clearDataUseCase: ClearDataUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository,
        listenDataUseCase: ListenDataUseCase,
        clearDataUseCase: ClearDataUseCase
    ) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
        self.listenDataUseCase = listenDataUseCase
        self.clearDataUseCase = clearDataUseCase
        updateDataListening()
    }
    
    private func updateDataListening() {
        authenticationRepository.authenticated
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.listenDataUseCase.start()
                } else {
                    self?.listenDataUseCase.stop()
                    Task { await self?.clearDataUseCase.execute() }
                }
            }.store(in: &cancellables)
    }
}
