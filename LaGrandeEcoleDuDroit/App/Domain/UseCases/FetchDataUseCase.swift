import Combine

private let tag = String(describing: FetchDataUseCase.self)

class FetchDataUseCase {
    private let networkMonitor: NetworkMonitor
    private let fetchBlockedUsersUseCase: FetchBlockedUsersUseCase
    private let fetchAnnouncementsUseCase: FetchAnnouncementsUseCase
    private let fetchMissionsUseCase: FetchMissionsUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        networkMonitor: NetworkMonitor,
        fetchBlockedUsersUseCase: FetchBlockedUsersUseCase,
        fetchAnnouncementsUseCase: FetchAnnouncementsUseCase,
        fetchMissionsUseCase: FetchMissionsUseCase
    ) {
        self.networkMonitor = networkMonitor
        self.fetchBlockedUsersUseCase = fetchBlockedUsersUseCase
        self.fetchAnnouncementsUseCase = fetchAnnouncementsUseCase
        self.fetchMissionsUseCase = fetchMissionsUseCase
    }
    
    func execute() {
        networkMonitor.connected
            .first { $0 }
            .sink { [weak self] _ in
                Task {
                    do {
                        try await self?.fetchBlockedUsersUseCase.execute()
                        try await self?.fetchAnnouncementsUseCase.execute()
                        try await self?.fetchMissionsUseCase.execute()
                    } catch {
                        e(tag, "Failed to fetch data", error)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
