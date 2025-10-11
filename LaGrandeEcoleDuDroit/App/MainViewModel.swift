import Combine
import Foundation

class MainViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let listenDataUseCase: ListenDataUseCase
    private let clearDataUseCase: ClearDataUseCase
    private let listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    private let synchronizeDataUseCase: SynchronizeDataUseCase
    private let checkUserValidityUseCase: CheckUserValidityUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userRepository: UserRepository,
        listenDataUseCase: ListenDataUseCase,
        clearDataUseCase: ClearDataUseCase,
        listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase,
        synchronizeDataUseCase: SynchronizeDataUseCase,
        checkUserValidityUseCase: CheckUserValidityUseCase
    ) {
        self.userRepository = userRepository
        self.listenDataUseCase = listenDataUseCase
        self.clearDataUseCase = clearDataUseCase
        self.listenAuthenticationStateUseCase = listenAuthenticationStateUseCase
        self.synchronizeDataUseCase = synchronizeDataUseCase
        self.checkUserValidityUseCase = checkUserValidityUseCase
        
        updateDataOnAuthChange()
    }
    
    private func updateDataOnAuthChange() {
        listenAuthenticationStateUseCase.authenticated
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] authenticated in
                if authenticated {
                    Task {
                        await self?.checkUserValidityUseCase.execute()
                        self?.listenDataUseCase.start()
                        self?.synchronizeDataUseCase.execute()
                    }
                } else {
                    self?.listenDataUseCase.stop()
                    Task {
                        await sleep(2)
                        await self?.clearDataUseCase.execute()
                    }
                }
            }.store(in: &cancellables)
    }
}
