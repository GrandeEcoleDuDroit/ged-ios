class DeleteAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcementId: String, state: AnnouncementState) async throws {
        if case state = .error {
            await announcementRepository.deleteLocalAnnouncement(announcementId: announcementId)
        } else {
            try await announcementRepository.deleteAnnouncement(announcementId: announcementId)
        }
    }
}
