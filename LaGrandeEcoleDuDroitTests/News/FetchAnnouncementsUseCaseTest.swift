import Testing
import Combine
import Foundation

@testable import GrandeEcoleDuDroit

class FetchAnnouncementsUseCaseTest {
    @Test
    func fetchAnnouncementsUseCase_should_upsert_new_remote_announcements() async {
        // Given
        let remoteAnnouncements = announcementsFixture
        let announcementsUpserted = AnnouncementsUpserted(
            declaredCurrentAnnouncements: [],
            declaredRemoteAnnouncements: remoteAnnouncements
        )
        let useCase = FetchAnnouncementsUseCase(
            announcementRepository: announcementsUpserted,
            blockedUserRepository: MockBlockedUserRepository()
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(announcementsUpserted.announcemenstUpserted == remoteAnnouncements)
    }
    
    @Test
    func fetchAnnouncementsUseCase_should_not_upsert_announcements_from_blocked_users() async {
        // Given
        let remoteAnnouncements = announcementsFixture
        let announcementsUpserted = AnnouncementsUpserted(
            declaredCurrentAnnouncements: [],
            declaredRemoteAnnouncements: remoteAnnouncements
        )
        let useCase = FetchAnnouncementsUseCase(
            announcementRepository: announcementsUpserted,
            blockedUserRepository: TestBlockedUserRepository(
                localBlockedUsers: remoteAnnouncements.map { BlockedUser(userId: $0.id, date: Date())}
            )
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(announcementsUpserted.announcemenstUpserted.isEmpty)
    }
    
    @Test
    func fetchAnnouncementsUseCase_should_delete_announcements_not_present_in_remote() async {
        // Given
        let currentAnnouncements = announcementsFixture
        let announcementsDeleted = AnnouncementsDeleted(
            declaredCurrentAnnouncements: currentAnnouncements,
            declaredRemoteAnnouncements: []
        )
        let useCase = FetchAnnouncementsUseCase(
            announcementRepository: announcementsDeleted,
            blockedUserRepository: MockBlockedUserRepository()
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(announcementsDeleted.announcementDeletedIds == currentAnnouncements.map { $0.id })
    }
    
    @Test
    func fetchAnnouncementsUseCase_should_delete_announcements_from_blocked_users() async {
        // Given
        let currentAnnouncements = announcementsFixture
        let announcementsDeleted = AnnouncementsDeleted(
            declaredCurrentAnnouncements: currentAnnouncements,
            declaredRemoteAnnouncements: currentAnnouncements
        )
        let useCase = FetchAnnouncementsUseCase(
            announcementRepository: announcementsDeleted,
            blockedUserRepository: TestBlockedUserRepository(
                localBlockedUsers: currentAnnouncements.map { BlockedUser(userId: $0.id, date: Date()) }
            )
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(announcementsDeleted.announcementDeletedIds == currentAnnouncements.map { $0.id })
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

private class TestBlockedUserRepository: MockBlockedUserRepository {
    private let localBlockedUsers: [BlockedUser]
    
    override var blockedUsers: AnyPublisher<[String: BlockedUser], Never> {
        Just(
            localBlockedUsers.reduce(into: [:]) { result, user in
                result[user.userId] = user
            }
        ).eraseToAnyPublisher()
    }
    
    override var currentBlockedUsers: [String: BlockedUser] {
        localBlockedUsers.reduce(into: [:]) { result, user in
            result[user.userId] = user
        }
    }
    
    init(localBlockedUsers: [BlockedUser]) {
        self.localBlockedUsers = localBlockedUsers
    }
}
