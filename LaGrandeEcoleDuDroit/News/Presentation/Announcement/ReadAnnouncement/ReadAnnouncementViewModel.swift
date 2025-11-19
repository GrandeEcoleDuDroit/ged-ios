import Foundation
import Combine

class ReadAnnouncementViewModel: ViewModel {
    private let announcementId: String
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState: ReadAnnouncementUiState = ReadAnnouncementUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        announcementId: String,
        userRepository: UserRepository,
        announcementRepository: AnnouncementRepository,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.announcementId = announcementId
        self.userRepository = userRepository
        self.announcementRepository = announcementRepository
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.networkMonitor = networkMonitor
        
        listenAnnouncement()
        listenUser()
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
        
    private func listenAnnouncement() {
        announcementRepository.getAnnouncementPublisher(announcementId: announcementId)
            .compactMap { $0 }
            .map { announcement in
                let title = announcement.title?.isBlank() == false ? announcement.title : nil
                return announcement.copy { $0.title = title }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] announcement in
                self?.uiState.announcement = announcement
            }.store(in: &cancellables)
    }
    
    private func listenUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }.store(in: &cancellables)
    }
    
    func deleteAnnouncement() {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: stringResource(.noInternetConectionError))
        }
        guard let announcement = uiState.announcement else {
            return
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.deleteAnnouncementUseCase.execute(announcement: announcement)
                self?.uiState.loading = false
                self?.event = SuccessEvent()
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    struct ReadAnnouncementUiState: Withable {
        var announcement: Announcement? = nil
        var user: User? = nil
        var loading: Bool = false
    }    
}
