import Combine
import Foundation

class MainViewModel: ObservableObject {
    private let networkMonitor: NetworkMonitor
    private let userRepository: UserRepository
    private let listenDataUseCase: ListenDataUseCase
    private let clearDataUseCase: ClearDataUseCase
    private let listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    private let fetchDataUseCase: FetchDataUseCase
    private let checkUserValidityUseCase: CheckUserValidityUseCase
    private let fcmTokenUseCase: FcmTokenUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        networkMonitor: NetworkMonitor,
        userRepository: UserRepository,
        listenDataUseCase: ListenDataUseCase,
        clearDataUseCase: ClearDataUseCase,
        listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase,
        fetchDataUseCase: FetchDataUseCase,
        checkUserValidityUseCase: CheckUserValidityUseCase,
        fcmTokenUseCase: FcmTokenUseCase
    ) {
        self.networkMonitor = networkMonitor
        self.userRepository = userRepository
        self.listenDataUseCase = listenDataUseCase
        self.clearDataUseCase = clearDataUseCase
        self.listenAuthenticationStateUseCase = listenAuthenticationStateUseCase
        self.fetchDataUseCase = fetchDataUseCase
        self.checkUserValidityUseCase = checkUserValidityUseCase
        self.fcmTokenUseCase = fcmTokenUseCase
        
        updateDataOnAuthChange()
    }
    
    private func updateDataOnAuthChange() {
        listenAuthenticationStateUseCase.authenticated
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] authenticated in
                if authenticated {
                    Task {
                        await self?.networkMonitor.connected.values.first { $0 }
                        await self?.checkUserValidityUseCase.execute()
                        await self?.fetchDataUseCase.execute()
                        self?.listenDataUseCase.start()
                        await self?.fcmTokenUseCase.sendUnsentToken()
                    }
                } else {
                    self?.listenDataUseCase.stop()
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        await self?.clearDataUseCase.execute()
                    }
                }
            }.store(in: &cancellables)
    }
}
