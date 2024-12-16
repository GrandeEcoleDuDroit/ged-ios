class DeleteAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) async throws {
        try await announcementRepository.deleteAnnouncement(announcement: announcement)
    }
}
