import Foundation
import Combine

private let tag = String(describing: AnnouncementDetailViewModel.self)

class AnnouncementDetailViewModel: ObservableObject {
    private let updateAnnouncementUseCase: UpdateAnnouncementUseCase
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    let currentUser: User?
    
    @Published private(set) var announcementState: AnnouncementState = .idle
    @Published var announcement: Announcement
    
    init(
        updateAnnouncementUseCase: UpdateAnnouncementUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        announcement: Announcement
    ) {
        self.updateAnnouncementUseCase = updateAnnouncementUseCase
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.announcement = announcement
        
        self.currentUser = getCurrentUserUseCase.execute().value
    }
    
    func updateAnnouncement(announcement: Announcement) {
        updateAnnouncementState(.loading)
        
        Task {
            do {
                try await updateAnnouncementUseCase.execute(announcement: announcement)
                updateAnnouncement(announcement)
                updateAnnouncementState(.updated)
            } catch {
                updateAnnouncementState(.error(message: error.localizedDescription))
                e(tag, error.localizedDescription)
            }
        }
    }
    
    func deleteAnnouncement() {
        updateAnnouncementState(.loading)
        
        Task {
            do {
                try await deleteAnnouncementUseCase.execute(announcement: announcement)
                updateAnnouncementState(.deleted)
            } catch {
                e(tag, error.localizedDescription)
                updateAnnouncementState(.error(message: error.localizedDescription))
            }
        }
    }
    
    func resetAnnouncementState() {
        updateAnnouncementState(.idle)
    }
    
    private func updateAnnouncement(_ announcement: Announcement) {
        if Thread.isMainThread {
            self.announcement = announcement
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.announcement = announcement
            }
        }
    }
    
    private func updateAnnouncementState(_ state: AnnouncementState) {
        if Thread.isMainThread {
            announcementState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.announcementState = state
            }
        }
    }
}
