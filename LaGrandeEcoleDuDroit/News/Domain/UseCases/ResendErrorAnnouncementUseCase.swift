class ResendErrorAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) async throws {
        do {
            await announcementRepository.updateAnnouncementState(announcementId: announcement.id, state: .sending)
            try await announcementRepository.createRemoteAnnouncement(announcement: announcement)
            await announcementRepository.updateAnnouncementState(announcementId: announcement.id, state: .published)
        } catch {
            await announcementRepository.updateAnnouncementState(announcementId: announcement.id, state: .error)
            throw error
        }
    }
}
