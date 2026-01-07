import Foundation
import Combine

class NewsViewModel: ViewModel {
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let recreateAnnouncementUseCase: RecreateAnnouncementUseCase
    private let refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState: NewsUiState = NewsUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userRepository: UserRepository,
        announcementRepository: AnnouncementRepository,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        recreateAnnouncementUseCase: RecreateAnnouncementUseCase,
        refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.userRepository = userRepository
        self.announcementRepository = announcementRepository
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.recreateAnnouncementUseCase = recreateAnnouncementUseCase
        self.refreshAnnouncementsUseCase = refreshAnnouncementsUseCase
        self.networkMonitor = networkMonitor
        
        listenUser()
        listenAnnouncements()
    }
    
    func refreshAnnouncements() async {
        try? await refreshAnnouncementsUseCase.execute()
    }

    
    func recreateAnnouncement(announcement: Announcement) {
        Task {
            await recreateAnnouncementUseCase.execute(announcement: announcement)
        }
    }
    
    func deleteAnnouncement(announcement: Announcement) {
        performRequest { [weak self] in
            try await self?.deleteAnnouncementUseCase.execute(announcement: announcement)
        }
    }
    
    func reportAnnouncement(report: AnnouncementReport) {
        performRequest { [weak self] in
            try await self?.announcementRepository.reportAnnouncement(report: report)
        }
    }
    
    func getAnnouncement(announcementId: String) -> Announcement? {
        announcementRepository.currentAnnouncements.first { $0.id == announcementId }
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: mapNetworkErrorMessage($0))
            },
            onFinally: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func listenUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }
            .store(in: &cancellables)
    }
    
    private func listenAnnouncements() {
        announcementRepository.announcements
            .map { [weak self] announcements in
                announcements.compactMap { self?.transform($0) }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] announcements in
                self?.uiState.announcements = announcements
            }
            .store(in: &cancellables)
    }
    
    private func transform(_ announcement: Announcement) -> Announcement {
        let trimmedTitle = announcement.title?.trim()
        let newTitle = trimmedTitle.flatMap { !$0.isEmpty ? String($0.prefix(100)) : nil }
        let newContent = String(announcement.content.prefix(100))
        
        return announcement.copy { $0.title = newTitle; $0.content = newContent }
    }
    
    struct NewsUiState {
        var user: User? = nil
        var announcements: [Announcement]? = nil
        var loading: Bool = false
    }
}
