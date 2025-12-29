import Combine
import Foundation

class MainViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let listenDataUseCase: ListenDataUseCase
    private let clearDataUseCase: ClearDataUseCase
    private let listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    private let fetchDataUseCase: FetchDataUseCase
    private let checkUserValidityUseCase: CheckUserValidityUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userRepository: UserRepository,
        listenDataUseCase: ListenDataUseCase,
        clearDataUseCase: ClearDataUseCase,
        listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase,
        fetchDataUseCase: FetchDataUseCase,
        checkUserValidityUseCase: CheckUserValidityUseCase
    ) {
        self.userRepository = userRepository
        self.listenDataUseCase = listenDataUseCase
        self.clearDataUseCase = clearDataUseCase
        self.listenAuthenticationStateUseCase = listenAuthenticationStateUseCase
        self.fetchDataUseCase = fetchDataUseCase
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
                        self?.fetchDataUseCase.execute()
                        self?.listenDataUseCase.start()
                    }
                } else {
                    self?.listenDataUseCase.stop()
                    Task {
                        try await Task.sleep(for: .seconds(2))
                        await self?.clearDataUseCase.execute()
                    }
                }
            }.store(in: &cancellables)
    }
}
