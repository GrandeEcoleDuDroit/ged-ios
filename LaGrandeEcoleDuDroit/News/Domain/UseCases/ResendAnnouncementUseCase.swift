class ResendAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository

    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) {
        do {
            try await announcementRepository.createAnnouncement(announcement: announcement.copy { $0.state = .publishing })
            try await announcementRepository.upsertLocalAnnouncement(announcement: announcement.copy { $0.state = .published })
        } catch {
            try? await announcementRepository.upsertLocalAnnouncement(announcement: announcement.copy { $0.state = .error })
        }
    }
}
