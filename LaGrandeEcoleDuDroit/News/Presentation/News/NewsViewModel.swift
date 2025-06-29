import Foundation
import Combine

private let tag = String(describing: NewsViewModel.self)

class NewsViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let recreateAnnouncementUseCase: ResendAnnouncementUseCase
    private let refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: NewsUiState = NewsUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        userRepository: UserRepository,
        announcementRepository: AnnouncementRepository,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        recreateAnnouncementUseCase: ResendAnnouncementUseCase,
        refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    ) {
        self.userRepository = userRepository
        self.announcementRepository = announcementRepository
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.recreateAnnouncementUseCase = recreateAnnouncementUseCase
        self.refreshAnnouncementsUseCase = refreshAnnouncementsUseCase
        newsUiState()
        Task { await refreshAnnouncements() }
    }
    
    func refreshAnnouncements() async {
        do {
            try await refreshAnnouncementsUseCase.execute()
        } catch {
            updateEvent(ErrorEvent(message: mapErrorMessage(error)))
        }
    }

    
    func resendAnnouncement(announcement: Announcement) {
        do {
            try recreateAnnouncementUseCase.execute(announcement: announcement)
        } catch {
            updateEvent(ErrorEvent(message: mapErrorMessage(error)))
        }
    }
    
    func deleteAnnouncement(announcement: Announcement) {
        Task {
            do {
                try await deleteAnnouncementUseCase.execute(announcement: announcement)
            } catch {
                updateEvent(ErrorEvent(message: mapErrorMessage(error)))
            }
        }
    }
    
    private func updateEvent(_ event: SingleUiEvent) {
        DispatchQueue.main.async { [weak self] in
            self?.event = event
        }
    }
    
    private func newsUiState() {
        Publishers.CombineLatest(
            userRepository.user,
            announcementRepository.announcements
        )
        .map { user, announcements in
            let trimmedAnnouncements = announcements.map { self.transform($0) }
            return NewsUiState(
                user: user,
                announcements: trimmedAnnouncements,
                refreshing: self.uiState.refreshing
            )
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in
            self?.uiState = state
        }
        .store(in: &cancellables)
    }
    
    private func transform(_ announcement: Announcement) -> Announcement {
        let trimmedTitle = announcement.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let newTitle = trimmedTitle.flatMap { !$0.isEmpty ? String($0.prefix(100)) : nil }
        let newContent = String(announcement.content.prefix(100))
        
        return announcement.with(title: newTitle, content: newContent)
    }
    
    private func mapErrorMessage(_ error: Error) -> String {
        if let error = error as? NetworkError {
            switch error {
                case .noInternetConnection: getString(.noInternetConectionError)
                default: getString(.announcement_refresh_error)
            }
        } else {
            getString(.unknownError)
        }
    }
    
    struct NewsUiState: Withable {
        var user: User? = nil
        var announcements: [Announcement]? = nil
        var refreshing: Bool = false
    }
}
