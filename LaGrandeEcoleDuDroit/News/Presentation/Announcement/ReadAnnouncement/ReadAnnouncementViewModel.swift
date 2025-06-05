import Foundation
import Combine

class ReadAnnouncementViewModel: ObservableObject {
    private let announcementId: String
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: ReadAnnouncementUiState = ReadAnnouncementUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        announcementId: String,
        userRepository: UserRepository,
        announcementRepository: AnnouncementRepository,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    ) {
        self.announcementId = announcementId
        self.userRepository = userRepository
        self.announcementRepository = announcementRepository
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        
        initUiState()
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
