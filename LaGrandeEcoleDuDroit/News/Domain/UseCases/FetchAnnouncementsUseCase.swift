class FetchAnnouncementsUseCase {
    private let announcementRepository: AnnouncementRepository
    private let blockedUserRepository: BlockedUserRepository
    
    init(
        announcementRepository: AnnouncementRepository,
        blockedUserRepository: BlockedUserRepository
    ) {
        self.announcementRepository = announcementRepository
        self.blockedUserRepository = blockedUserRepository
    }
    
    func execute() async throws {
        let announcements = announcementRepository.currentAnnouncements
        let remoteAnnouncements = try await announcementRepository.getRemoteAnnouncements()
        let blockedUsers = blockedUserRepository.currentBlockedUsers
        
        let announcementToDelete = announcements.filter {
            ($0.state == .published && !remoteAnnouncements.contains($0)) ||
            blockedUsers.has($0.author.id)
        }
        let announcementToUpsert = remoteAnnouncements.filter {
            !announcements.contains($0) && !blockedUsers.has($0.author.id)
        }
        
        for announcement in announcementToDelete {
            try? await announcementRepository.deleteLocalAnnouncement(announcementId: announcement.id)
        }
        for announcement in announcementToUpsert {
            try? await announcementRepository.upsertLocalAnnouncement(announcement: announcement)
        }
    }
}
