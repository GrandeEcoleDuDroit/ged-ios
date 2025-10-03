class DeleteAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) async throws {
        if case announcement.state = .published {
            try await announcementRepository.deleteAnnouncement(announcementId: announcement.id)
        } else {
            try await announcementRepository.deleteLocalAnnouncement(announcementId: announcement.id)
        }
    }
}
