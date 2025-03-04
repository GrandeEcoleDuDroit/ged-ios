import Foundation

class CreateAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) async {
        do {
            try await announcementRepository.createAnnouncement(announcement: announcement.with(state: .sending))
            await announcementRepository.updateAnnouncementState(announcementId: announcement.id, state: .published)
        } catch {
            await announcementRepository.updateAnnouncementState(announcementId: announcement.id, state: .error)
        }
    }
}
