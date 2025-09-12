import Combine
import Foundation

class MainViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let authenticationRepository: AuthenticationRepository
    private let listenDataUseCase: ListenDataUseCase
    private let clearDataUseCase: ClearDataUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userRepository: UserRepository,
        authenticationRepository: AuthenticationRepository,
        listenDataUseCase: ListenDataUseCase,
        clearDataUseCase: ClearDataUseCase
    ) {
        self.userRepository = userRepository
        self.authenticationRepository = authenticationRepository
        self.listenDataUseCase = listenDataUseCase
        self.clearDataUseCase = clearDataUseCase
        checkCurrentUser()
        updateDataListening()
    }
    
    private func updateDataListening() {
        authenticationRepository.authenticated
            .map { authenticated in
                let currentUser = self.userRepository.getCurrentUser()
                return authenticated && currentUser != nil
            }
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] validUser in
                if validUser {
                    self?.listenDataUseCase.start()
                } else {
                    self?.listenDataUseCase.stop()
                    Task { await self?.clearDataUseCase.execute() }
                }
            }.store(in: &cancellables)
    }
    
    private func checkCurrentUser() {
        guard let user = userRepository.getCurrentUser() else {
            authenticationRepository.logout()
            return
        }
    }
}
