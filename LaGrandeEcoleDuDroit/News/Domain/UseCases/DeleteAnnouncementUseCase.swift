class DeleteAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    private let announcementTaskReferences: AnnouncementTaskReferences
    
    init(
        announcementRepository: AnnouncementRepository,
        announcementTaskReferences: AnnouncementTaskReferences
    ) {
        self.announcementRepository = announcementRepository
        self.announcementTaskReferences = announcementTaskReferences
    }
    
    func execute(announcement: Announcement) async throws {
        switch announcement.state {
            case .published:
                try await announcementRepository.deleteAnnouncement(
                    announcementId: announcement.id,
                    authorId: announcement.author.id
                )
                
            case .publishing:
                await announcementTaskReferences.cancelTask(for: announcement.id)
                try await announcementRepository.deleteLocalAnnouncement(announcementId: announcement.id)
                
            case .error, .draft:
                try await announcementRepository.deleteLocalAnnouncement(announcementId: announcement.id)
        }
    }
}
