class RefreshAnnouncementsUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute() async throws {
        try await announcementRepository.refreshAnnouncements()
    }
}
