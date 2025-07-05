import Foundation

class CreateAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) {
        Task {
            do {
                try await announcementRepository.createAnnouncement(announcement: announcement.with(state: .publishing))
                try await announcementRepository.updateLocalAnnouncement(announcement: announcement.with(state: .published))
            } catch {
                try? await announcementRepository.updateLocalAnnouncement(announcement: announcement.with(state: .error))
            }
        }
    }
}
