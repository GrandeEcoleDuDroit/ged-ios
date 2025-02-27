class DeleteAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcementId: String, state: AnnouncementState) async throws {
        switch state {
            case .error, .sending:
                await announcementRepository.deleteLocalAnnouncement(announcementId: announcementId)
            default:
                try await announcementRepository.deleteAnnouncement(announcementId: announcementId)
        }
    }
}
