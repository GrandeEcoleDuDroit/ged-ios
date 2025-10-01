class ResendAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository

    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute(announcement: Announcement) async {
        do {
            try await announcementRepository.createAnnouncement(announcement: announcement.copy { $0.state = .publishing })
            try await announcementRepository.updateLocalAnnouncement(announcement: announcement.copy { $0.state = .published })
        } catch {
            try? await announcementRepository.updateLocalAnnouncement(announcement: announcement.copy { $0.state = .error })
        }
    }
}
