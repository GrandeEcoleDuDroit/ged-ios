import Foundation
import Combine

class ReadAnnouncementViewModel: ObservableObject {
    private let announcementId: String
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let networkMonitor: NetworkMonitor
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: ReadAnnouncementUiState = ReadAnnouncementUiState()
    @Published var event: SingleUiEvent? = nil
    
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
        
        initUiState()
    }
    
    func reportAnnouncement(report: AnnouncementReport) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task {
            do {
                try await announcementRepository.reportAnnouncement(report: report)
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    self?.updateEvent(ErrorEvent(message: mapNetworkErrorMessage(error)))
                }
            }
        }
    }
    
    private func initUiState() {
        Publishers.CombineLatest(
            announcementRepository.getAnnouncementPublisher(announcementId: announcementId),
            userRepository.user
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] announcement, user in
            self?.uiState.announcement = announcement
            self?.uiState.user = user
        }.store(in: &cancellables)
    }
    
    func deleteAnnouncement() {
        guard let announcement = uiState.announcement else { return }
        uiState.loading = true
        Task {
            do {
                try await deleteAnnouncementUseCase.execute(announcement: announcement)
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
                updateEvent(SuccessEvent())
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
                updateEvent(ErrorEvent(message: mapNetworkErrorMessage(error)))
            }
        }
    }
    
    private func updateEvent(_ event: SingleUiEvent) {
        DispatchQueue.main.sync { [weak self] in
            self?.event = event
        }
    }
    
    struct ReadAnnouncementUiState: Withable {
        var announcement: Announcement? = nil
        var user: User? = nil
        var loading: Bool = false
    }
}
