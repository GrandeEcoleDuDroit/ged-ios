import Foundation
import Combine

private let tag = String(describing: ReadAnnouncementViewModel.self)

class ReadAnnouncementViewModel: ObservableObject {
    private let updateAnnouncementUseCase: UpdateAnnouncementUseCase
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let getAnnouncementUseCase: GetAnnouncementUseCase
    private var cancellables: Set<AnyCancellable> = []
    let currentUser: User?
    
    @Published private(set) var screenState: AnnouncementScreenState = .idle
    @Published var announcement: Announcement
    
    init(
        updateAnnouncementUseCase: UpdateAnnouncementUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementUseCase: GetAnnouncementUseCase,
        announcement: Announcement
    ) {
        self.updateAnnouncementUseCase = updateAnnouncementUseCase
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementUseCase = getAnnouncementUseCase
        self.announcement = announcement
        self.currentUser = getCurrentUserUseCase.execute().value
        
        listenAnnouncement()
    }
    
    func deleteAnnouncement() {
        updateScreenState(.loading)
        
        Task {
            do {
                try await deleteAnnouncementUseCase.execute(announcementId: announcement.id, state: announcement.state)
                updateScreenState(.success)
            } catch {
                e(tag, error.localizedDescription)
                updateScreenState(.error(message: error.localizedDescription))
            }
        }
    }
    
    func resetAnnouncementState() {
        updateScreenState(.idle)
    }
    
    private func listenAnnouncement() {
        getAnnouncementUseCase.execute(announcementId: announcement.id)
            .receive(on: RunLoop.main)
            .sink { [weak self] announcement in
                self?.announcement = announcement
            }
            .store(in: &cancellables)
    }
    
    private func updateScreenState(_ state: AnnouncementScreenState) {
        if Thread.isMainThread {
            screenState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.screenState = state
            }
        }
    }
}
