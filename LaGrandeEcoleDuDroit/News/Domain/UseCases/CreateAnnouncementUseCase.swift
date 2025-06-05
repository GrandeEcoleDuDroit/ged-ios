import Foundation

class CreateAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) {
        Task {
            do {
                announcementRepository.createLocalAnnouncement(announcement: announcement)
                try await announcementRepository.createRemoteAnnouncement(announcement: announcement)
                announcementRepository.updateLocalAnnouncement(announcement: announcement.with(state: .published))
            } catch {
                announcementRepository.updateLocalAnnouncement(announcement: announcement.with(state: .error))
            }
        }
    }
}
