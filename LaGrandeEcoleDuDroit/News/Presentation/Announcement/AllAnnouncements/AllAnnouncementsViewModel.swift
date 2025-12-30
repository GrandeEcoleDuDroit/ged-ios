import Combine
import Foundation

class AllAnnouncementsViewModel: ViewModel {
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let recreateAnnouncementUseCase: RecreateAnnouncementUseCase
    private let refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState: AllAnnouncementsUiState = AllAnnouncementsUiState()
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
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: stringResource(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            await self?.recreateAnnouncementUseCase.execute(announcement: announcement)
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
            return event = ErrorEvent(message: stringResource(.noInternetConectionError))
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] announcements in
                self?.uiState.announcements = announcements
            }
            .store(in: &cancellables)
    }
    
    struct AllAnnouncementsUiState {
        fileprivate(set) var announcements: [Announcement]? = nil
        fileprivate(set) var user: User? = nil
        fileprivate(set) var loading: Bool = false
    }
}
