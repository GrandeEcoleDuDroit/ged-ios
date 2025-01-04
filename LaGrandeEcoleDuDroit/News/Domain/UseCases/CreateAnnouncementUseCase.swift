import Foundation

class CreateAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) async throws {
        do {
            try await announcementRepository.createAnnouncement(announcement: announcement.with(state: .loading))
            try await announcementRepository.updateAnnouncement(announcement: announcement.with(state: .created))
        } catch {
            try await announcementRepository.updateAnnouncement(announcement: announcement.with(state: .error(message: error.localizedDescription.description)))
            print(error.localizedDescription)
            throw error
        }
    }
}
