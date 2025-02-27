import Foundation

private let tag = String(describing: EditAnnouncementViewModel.self)

class EditAnnouncementViewModel: ObservableObject {
    private let updateAnnouncementUseCase: UpdateAnnouncementUseCase
    @Published var announcement: Announcement
    @Published private(set) var screenState: AnnouncementScreenState = .idle
    
    init(
        updateAnnouncementUseCase: UpdateAnnouncementUseCase,
        announcement: Announcement
    ) {
        self.updateAnnouncementUseCase = updateAnnouncementUseCase
        self.announcement = announcement
    }
    
    func updateAnnouncement() {
        updateScreenState(.loading)
        
        Task {
            do {
                try await updateAnnouncementUseCase.execute(announcement: announcement)
                updateScreenState(.success)
            } catch {
                updateScreenState(.error(message: error.localizedDescription))
                e(tag, error.localizedDescription)
            }
        }
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
