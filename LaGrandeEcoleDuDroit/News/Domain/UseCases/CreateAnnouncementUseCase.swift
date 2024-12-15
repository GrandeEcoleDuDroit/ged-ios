import Foundation

class CreateAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) async throws {
        let loadingAnnouncement = announcement.with(state: .loading)
        
        do {
            try await announcementRepository.createAnnouncement(announcement: announcement)
            let createdAnnouncement = announcement.with(state: .created)
            try await announcementRepository.updateAnnouncement(announcement: createdAnnouncement)
        } catch {
            let errorAnnouncement = announcement.with(state: .error(message: error.localizedDescription.description))
            try await announcementRepository.updateAnnouncement(announcement: errorAnnouncement)
            print(error.localizedDescription)
            throw error
        }
    }
}
