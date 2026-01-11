import Combine

class FetchDataUseCase {
    private let fetchBlockedUsersUseCase: FetchBlockedUsersUseCase
    private let fetchAnnouncementsUseCase: FetchAnnouncementsUseCase
    private let fetchMissionsUseCase: FetchMissionsUseCase
    private let tag = String(describing: FetchDataUseCase.self)
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        fetchBlockedUsersUseCase: FetchBlockedUsersUseCase,
        fetchAnnouncementsUseCase: FetchAnnouncementsUseCase,
        fetchMissionsUseCase: FetchMissionsUseCase
    ) {
        self.fetchBlockedUsersUseCase = fetchBlockedUsersUseCase
        self.fetchAnnouncementsUseCase = fetchAnnouncementsUseCase
        self.fetchMissionsUseCase = fetchMissionsUseCase
    }
    
    func execute() async {
        do {
            try await fetchBlockedUsersUseCase.execute()
            try await fetchAnnouncementsUseCase.execute()
            try await fetchMissionsUseCase.execute()
        } catch {
            w(tag, "Error fetching data: \(error.localizedDescription)")
        }
    }
}
