import Foundation
import Combine

private let tag = String(describing: NewsViewModel.self)

class NewsViewModel: ObservableObject {
    private let getAnnouncementsUseCase: GetAnnouncementsUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let resendErrorAnnouncementUseCase: ResendErrorAnnouncementUseCase
    private var cancellables: Set<AnyCancellable> = []
    var currentUser: User? = nil
    
    @Published private(set) var announcements: [Announcement] = []
    @Published private(set) var screenState: AnnouncementScreenState = .idle
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementsUseCase: GetAnnouncementsUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        resendErrorAnnouncementUseCase: ResendErrorAnnouncementUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementsUseCase = getAnnouncementsUseCase
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.resendErrorAnnouncementUseCase = resendErrorAnnouncementUseCase
        
        initCurrentUser()
        initAnnouncements()
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
            } catch {
                updateScreenState(.error(message: error.localizedDescription))
            }
        }
    }
    
    private func initCurrentUser() {
        getCurrentUserUseCase.execute().sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
    }
    
    private func initAnnouncements() {
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
