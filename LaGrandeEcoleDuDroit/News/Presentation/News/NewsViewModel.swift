import Foundation
import Combine

class NewsViewModel: ViewModel {
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let resendAnnouncementUseCase: ResendAnnouncementUseCase
    private let refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState: NewsUiState = NewsUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userRepository: UserRepository,
        announcementRepository: AnnouncementRepository,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        resendAnnouncementUseCase: ResendAnnouncementUseCase,
        refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.userRepository = userRepository
        self.announcementRepository = announcementRepository
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.resendAnnouncementUseCase = resendAnnouncementUseCase
        self.refreshAnnouncementsUseCase = refreshAnnouncementsUseCase
        self.networkMonitor = networkMonitor
        
        listenUser()
        listenAnnouncements()
    }
    
    func refreshAnnouncements() async {
        try? await refreshAnnouncementsUseCase.execute()
    }

    
    func resendAnnouncement(announcement: Announcement) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            await self?.resendAnnouncementUseCase.execute(announcement: announcement)
            self?.uiState.loading = false
        }
    }
    
    func deleteAnnouncement(announcement: Announcement) {
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.deleteAnnouncementUseCase.execute(announcement: announcement)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    func reportAnnouncement(report: AnnouncementReport) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.announcementRepository.reportAnnouncement(report: report)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
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
        let trimmedTitle = announcement.title?.trimmingCharacters(in: .whitespacesAndNewlines)
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
