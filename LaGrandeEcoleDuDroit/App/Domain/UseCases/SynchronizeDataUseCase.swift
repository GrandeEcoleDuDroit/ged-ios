import Combine

class SynchronizeDataUseCase {
    private let synchronizeBlockedUsersUseCase: SynchronizeBlockedUsersUseCase
    private let synchronizeAnnouncementsUseCase: SynchronizeAnnouncementsUseCase
    private let networkMonitor: NetworkMonitor
    private let tag = String(describing: SynchronizeDataUseCase.self)
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        synchronizeBlockedUsersUseCase: SynchronizeBlockedUsersUseCase,
        synchronizeAnnouncementsUseCase: SynchronizeAnnouncementsUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.synchronizeBlockedUsersUseCase = synchronizeBlockedUsersUseCase
        self.synchronizeAnnouncementsUseCase = synchronizeAnnouncementsUseCase
        self.networkMonitor = networkMonitor
    }
    
    func execute() {
        networkMonitor.connected
            .first { $0 }
            .sink { [weak self] _ in
                Task {
                    do {
                        try await self?.synchronizeBlockedUsersUseCase.execute()
                        try await self?.synchronizeAnnouncementsUseCase.execute()
                    } catch {
                        e(self?.tag ?? "", "Failed to synchronize data: \(error)", error)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
