class DeleteAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    private let announcementTaskQueue: AnnouncementTaskQueue
    
    init(
        announcementRepository: AnnouncementRepository,
        announcementTaskQueue: AnnouncementTaskQueue
    ) {
        self.announcementRepository = announcementRepository
        self.announcementTaskQueue = announcementTaskQueue
    }
    
    func execute(announcement: Announcement) async throws {
        switch announcement.state {
            case .published:
                try await announcementRepository.deleteAnnouncement(
                    announcementId: announcement.id,
                    authorId: announcement.author.id
                )
                
            case .publishing:
                await announcementTaskQueue.cancelTask(for: announcement.id)
                try await announcementRepository.deleteLocalAnnouncement(announcementId: announcement.id)
                
            case .error, .draft:
                try await announcementRepository.deleteLocalAnnouncement(announcementId: announcement.id)
        }
    }
}
