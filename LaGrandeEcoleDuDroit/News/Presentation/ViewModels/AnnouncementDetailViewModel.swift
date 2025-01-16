import Foundation
import Combine

private let tag = String(describing: AnnouncementDetailViewModel.self)

class AnnouncementDetailViewModel: ObservableObject {
    private let updateAnnouncementUseCase: UpdateAnnouncementUseCase
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    let currentUser: User?
    
    @Published private(set) var announcementState: AnnouncementState = .idle
    
    init(
        updateAnnouncementUseCase: UpdateAnnouncementUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase
    ) {
        self.updateAnnouncementUseCase = updateAnnouncementUseCase
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        
        self.currentUser = getCurrentUserUseCase.execute()
    }
    
    func updateAnnouncement(announcement: Announcement) {
        updateAnnouncementState(to: .loading)
        
        let task = Task {
            do {
                try await updateAnnouncementUseCase.execute(announcement: announcement)
                updateAnnouncementState(to: .updated)
            } catch {
                updateAnnouncementState(to: .error(message: error.localizedDescription))
                e(tag, error.localizedDescription)
            }
        }
    }
    
    func deleteAnnouncement(announcement: Announcement) {
        updateAnnouncementState(to: .loading)
        
        let task = Task {
            do {
                try await deleteAnnouncementUseCase.execute(announcement: announcement)
                updateAnnouncementState(to: .deleted)
            } catch {
                e(tag, error.localizedDescription)
                updateAnnouncementState(to: .error(message: error.localizedDescription))
            }
        }
    }
    
    func resetAnnouncementState() {
        updateAnnouncementState(to: .idle)
    }
    
    private func updateAnnouncementState(to state: AnnouncementState) {
        DispatchQueue.main.sync { [weak self] in
            self?.announcementState = state
        }
    }
}
