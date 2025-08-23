import Combine
import Foundation

class ReadAnnouncementViewModel: ObservableObject {
    private let announcementId: String
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let loadImageUseCase: LoadImageUseCase
    private var cancellables: Set<AnyCancellable> = []

    @Published var uiState: ReadAnnouncementUiState = ReadAnnouncementUiState()
    @Published var event: SingleUiEvent? = nil

    init(
        announcementId: String,
        userRepository: UserRepository,
        announcementRepository: AnnouncementRepository,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        loadImageUseCase: LoadImageUseCase
    ) {
        self.announcementId = announcementId
        self.userRepository = userRepository
        self.announcementRepository = announcementRepository
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.loadImageUseCase = loadImageUseCase

        initUiState()
    }

    private func initUiState() {
        Publishers.CombineLatest(
            announcementRepository.getAnnouncementPublisher(
                announcementId: announcementId
            ),
            userRepository.user
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] announcement, user in
            self?.uiState.announcement = announcement
            self?.uiState.user = user
            if let userPictureUrl = user.profilePictureUrl {
                self?.loadUserImage(url: userPictureUrl)
            } else {
                self?.uiState.user = self?.uiState.user?.with(imagePhase: .empty)
            }
        }.store(in: &cancellables)
    }

    func deleteAnnouncement() {
        guard let announcement = uiState.announcement else { return }
        uiState.loading = true
        Task {
            do {
                try await deleteAnnouncementUseCase.execute(
                    announcement: announcement
                )
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

    private func loadUserImage(url: String) {
        uiState.user = uiState.user?.with(imagePhase: .loading)
        Task {
            let phase = await loadImageUseCase.execute(url: url)
            DispatchQueue.main.sync { [weak self] in
                self?.uiState.user = self?.uiState.user?.with(imagePhase: phase)
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
