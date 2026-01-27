import Combine

class FetchDataUseCase {
    private let fetchCurrentUserUseCase: FetchCurrentUserUseCase
    private let fetchBlockedUsersUseCase: FetchBlockedUsersUseCase
    private let fetchAnnouncementsUseCase: FetchAnnouncementsUseCase
    private let fetchMissionsUseCase: FetchMissionsUseCase
    private let tag = String(describing: FetchDataUseCase.self)
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        fetchCurrentUserUseCase: FetchCurrentUserUseCase,
        fetchBlockedUsersUseCase: FetchBlockedUsersUseCase,
        fetchAnnouncementsUseCase: FetchAnnouncementsUseCase,
        fetchMissionsUseCase: FetchMissionsUseCase
    ) {
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.fetchBlockedUsersUseCase = fetchBlockedUsersUseCase
        self.fetchAnnouncementsUseCase = fetchAnnouncementsUseCase
        self.fetchMissionsUseCase = fetchMissionsUseCase
    }
    
    func execute(userId: String) async {
        do {
            try await fetchCurrentUserUseCase.execute(userId: userId)
            try await fetchBlockedUsersUseCase.execute(userId: userId)
            try await fetchAnnouncementsUseCase.execute()
            try await fetchMissionsUseCase.execute()
        } catch {
            w(tag, "Error fetching data: \(error.localizedDescription)")
        }
    }
}
