import Combine

class FetchDataUseCase {
    private let fetchCurrentUserUseCase: FetchCurrentUserUseCase
    private let fetchBlockedUsersUseCase: FetchBlockedUsersUseCase
    private let fetchAnnouncementsUseCase: FetchAnnouncementsUseCase
    private let fetchPostsUseCase: FetchPostsUseCase
    private let fetchMissionsUseCase: FetchMissionsUseCase
    
    private let tag = String(describing: FetchDataUseCase.self)
    
    init(
        fetchCurrentUserUseCase: FetchCurrentUserUseCase,
        fetchBlockedUsersUseCase: FetchBlockedUsersUseCase,
        fetchAnnouncementsUseCase: FetchAnnouncementsUseCase,
        fetchPostsUseCase: FetchPostsUseCase,
        fetchMissionsUseCase: FetchMissionsUseCase
    ) {
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.fetchBlockedUsersUseCase = fetchBlockedUsersUseCase
        self.fetchAnnouncementsUseCase = fetchAnnouncementsUseCase
        self.fetchPostsUseCase = fetchPostsUseCase
        self.fetchMissionsUseCase = fetchMissionsUseCase
    }
    
    func execute(userId: String) async {
        do {
            try await fetchCurrentUserUseCase.execute(userId: userId)
            try await fetchBlockedUsersUseCase.execute(userId: userId)
            try await fetchAnnouncementsUseCase.execute()
            try await fetchPostsUseCase.execute()
            try await fetchMissionsUseCase.execute()
        } catch {
            w(tag, "Error fetching data: \(error.localizedDescription)")
        }
    }
}
