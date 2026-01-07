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
        performRequest { [weak self] in
            try await self?.announcementRepository.reportAnnouncement(report: report)
        }
    }
        
    func deleteAnnouncement() {
        guard let announcement = uiState.announcement else { return }
        performRequest { [weak self] in
            try await self?.deleteAnnouncementUseCase.execute(announcement: announcement)
            self?.event = SuccessEvent()
        }
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
    
    struct ReadAnnouncementUiState: Withable {
        var announcement: Announcement? = nil
        var user: User? = nil
        var loading: Bool = false
    }    
}
