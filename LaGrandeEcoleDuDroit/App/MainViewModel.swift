import Combine
import Foundation

class MainViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let listenDataUseCase: ListenDataUseCase
    private let clearDataUseCase: ClearDataUseCase
    private let listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    private let synchronizeDataUseCase: SynchronizeDataUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userRepository: UserRepository,
        listenDataUseCase: ListenDataUseCase,
        clearDataUseCase: ClearDataUseCase,
        listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase,
        synchronizeDataUseCase: SynchronizeDataUseCase
    ) {
        self.userRepository = userRepository
        self.listenDataUseCase = listenDataUseCase
        self.clearDataUseCase = clearDataUseCase
        self.listenAuthenticationStateUseCase = listenAuthenticationStateUseCase
        self.synchronizeDataUseCase = synchronizeDataUseCase
        
        updateDataOnAuthChange()
    }
    
    private func updateDataOnAuthChange() {
        listenAuthenticationStateUseCase.authenticated
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] authenticated in
                if authenticated {
                    self?.listenDataUseCase.start()
                    Task { await self?.synchronizeDataUseCase.execute() }
                } else {
                    self?.listenDataUseCase.stop()
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        await self?.clearDataUseCase.execute()
                    }
                }
            }.store(in: &cancellables)
    }
}
