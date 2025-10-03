import Testing

@testable import GrandeEcoleDuDroit

class SynchronizeAnnouncementsUseCaseTest {
    @Test
    func synchronizeAnnouncementsUseCase_should_delete_announcements_not_present_in_remote() async {
        // Given
        let currentAnnouncements = announcementsFixture
        let announcementsDeleted = AnnouncementsDeleted(
            declaredCurrentAnnouncements: currentAnnouncements,
            declaredRemoteAnnouncements: []
        )
        let useCase = SynchronizeAnnouncementsUseCase(
            announcementRepository: announcementsDeleted,
            blockedUserRepository: MockBlockedUserRepository()
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(announcementsDeleted.announcementDeletedIds == currentAnnouncements.map { $0.id })
    }
    
    @Test
    func synchronizeAnnouncementsUseCase_should_upsert_new_remote_announcements() async {
        // Given
        let remoteAnnouncements = announcementsFixture
        let announcementsUpserted = AnnouncementsUpserted(
            declaredCurrentAnnouncements: [],
            declaredRemoteAnnouncements: remoteAnnouncements
        )
        let useCase = SynchronizeAnnouncementsUseCase(
            announcementRepository: announcementsUpserted,
            blockedUserRepository: MockBlockedUserRepository()
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(announcementsUpserted.announcemenstUpserted == remoteAnnouncements)
    }
    
    @Test
    func synchronizeAnnouncementsUseCase_should_not_upsert_new_remote_announcements_from_blocked_users() async {
        // Given
        let remoteAnnouncements = announcementsFixture
        let announcementsUpserted = AnnouncementsUpserted(
            declaredCurrentAnnouncements: [],
            declaredRemoteAnnouncements: remoteAnnouncements
        )
        let useCase = SynchronizeAnnouncementsUseCase(
            announcementRepository: announcementsUpserted,
            blockedUserRepository: BlockedUsers(
                declaredBlockedUserIds: remoteAnnouncements.map { $0.author.id }.toSet()
            )
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(announcementsUpserted.announcemenstUpserted.isEmpty)
    }
}

private class AnnouncementsDeleted: MockAnnouncementRepository {
    var announcementDeletedIds: [String] = []
    private let declaredCurrentAnnouncements: [Announcement]
    private let declaredRemoteAnnouncements: [Announcement]
    
    init(
        declaredCurrentAnnouncements: [Announcement],
        declaredRemoteAnnouncements: [Announcement]
    ) {
        self.declaredCurrentAnnouncements = declaredCurrentAnnouncements
        self.declaredRemoteAnnouncements = declaredRemoteAnnouncements
    }
    
    override var currentAnnouncements: [Announcement] {
        declaredCurrentAnnouncements
    }
    
    override func deleteLocalAnnouncement(announcementId: String) {
        announcementDeletedIds.append(announcementId)
    }
    
    override func getRemoteAnnouncements() async throws -> [Announcement] {
        declaredRemoteAnnouncements
    }
}

private class AnnouncementsUpserted: MockAnnouncementRepository {
    var announcemenstUpserted: [Announcement] = []
    private let declaredCurrentAnnouncements: [Announcement]
    private let declaredRemoteAnnouncements: [Announcement]
    
    init(
        declaredCurrentAnnouncements: [Announcement],
        declaredRemoteAnnouncements: [Announcement]
    ) {
        self.declaredCurrentAnnouncements = declaredCurrentAnnouncements
        self.declaredRemoteAnnouncements = declaredRemoteAnnouncements
    }
    
    override var currentAnnouncements: [Announcement] {
        declaredCurrentAnnouncements
    }
    
    override func upsertLocalAnnouncement(announcement: Announcement) async throws {
        announcemenstUpserted.append(announcement)
    }
    
    override func getRemoteAnnouncements() async throws -> [Announcement] {
        declaredRemoteAnnouncements
    }
}

private class BlockedUsers: MockBlockedUserRepository {
    private let declaredBlockedUserIds: Set<String>
    
    init(declaredBlockedUserIds: Set<String>) {
        self.declaredBlockedUserIds = declaredBlockedUserIds
    }
    
    override func getLocalBlockedUserIds() -> Set<String> {
        declaredBlockedUserIds
    }
}
