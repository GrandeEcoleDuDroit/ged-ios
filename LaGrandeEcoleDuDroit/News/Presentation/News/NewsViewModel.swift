import Foundation
import Combine

class NewsViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let resendAnnouncementUseCase: ResendAnnouncementUseCase
    private let refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: NewsUiState = NewsUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        userRepository: UserRepository,
        announcementRepository: AnnouncementRepository,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        resendAnnouncementUseCase: ResendAnnouncementUseCase,
        refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    ) {
        self.userRepository = userRepository
        self.announcementRepository = announcementRepository
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.resendAnnouncementUseCase = resendAnnouncementUseCase
        self.refreshAnnouncementsUseCase = refreshAnnouncementsUseCase
        
        listenUser()
        listenAnnouncements()
    }
    
    func refreshAnnouncements() async {
        try? await refreshAnnouncementsUseCase.execute()
    }

    
    func resendAnnouncement(announcement: Announcement) {
        do {
            try resendAnnouncementUseCase.execute(announcement: announcement)
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
    
    func reportAnnouncement(report: AnnouncementReport) {
        Task {
            try? await announcementRepository.reportAnnouncement(report: report)
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
            .map { announcements in
                announcements.map { self.transform($0) }
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
    
    private func updateEvent(_ event: SingleUiEvent) {
        DispatchQueue.main.sync { [weak self] in
            self?.event = event
        }
    }
    
    struct NewsUiState {
        var user: User? = nil
        var announcements: [Announcement]? = nil
        var loading: Bool = false
    }
}
