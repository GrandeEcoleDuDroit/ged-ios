import Foundation
import Combine

private let tag = String(describing: NewsViewModel.self)

class NewsViewModel: ObservableObject {
    private let getAnnouncementsUseCase: GetAnnouncementsUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let resendErrorAnnouncementUseCase: ResendErrorAnnouncementUseCase
    private let refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    private var cancellables: Set<AnyCancellable> = []
    private(set) var currentUser: User? = nil
    
    @Published private(set) var announcements: [Announcement] = []
    @Published private(set) var screenState: AnnouncementScreenState = .initial
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementsUseCase: GetAnnouncementsUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        resendErrorAnnouncementUseCase: ResendErrorAnnouncementUseCase,
        refreshAnnouncementsUseCase: RefreshAnnouncementsUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementsUseCase = getAnnouncementsUseCase
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.resendErrorAnnouncementUseCase = resendErrorAnnouncementUseCase
        self.refreshAnnouncementsUseCase = refreshAnnouncementsUseCase
        
        initCurrentUser()
        initAnnouncements()
    }
    
    func refreshAnnouncements() async {
        await refreshAnnouncementsUseCase.execute()
    }
    
    func deleteAnnouncement(announcement: Announcement) {
        Task {
            try? await deleteAnnouncementUseCase.execute(announcementId: announcement.id, state: announcement.state)
        }
    }
    
    func resendAnnouncement(announcement: Announcement) {
        Task {
            do {
                try await resendErrorAnnouncementUseCase.execute(announcement: announcement)
            } catch let error as URLError {
                switch error.code {
                    case .notConnectedToInternet:
                        updateScreenState(.error(message: getString(.notConnectedToInternetError)))
                    case .timedOut:
                        updateScreenState(.error(message: getString(.timedOutError)))
                    case .networkConnectionLost:
                        updateScreenState(.error(message: getString(.networkConnectionLostError)))
                    case .cannotFindHost:
                        updateScreenState(.error(message: getString(.cannotFindHostError)))
                    default:
                        updateScreenState(.error(message: getString(.unknownNetworkError)))
                }
            } catch {
                updateScreenState(.error(message: getString(.unknownError)))
            }
        }
    }
    
    private func initCurrentUser() {
        getCurrentUserUseCase.execute().sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
    }
    
    private func initAnnouncements() {
        Task {
            await refreshAnnouncements()
        }
        
        getAnnouncementsUseCase.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] announcements in
                self?.announcements = announcements
            }
            .store(in: &cancellables)
    }
    
    func updateScreenState(_ state: AnnouncementScreenState) {
        if Thread.isMainThread {
            screenState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.screenState = state
            }
        }
    }
}
