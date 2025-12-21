import Testing

@testable import GrandeEcoleDuDroit

class DeleteAnnouncementUseCaseTest {
    @Test
    func deleteAnnouncementUseCase_should_delete_announcement_when_state_is_published() async {
        // Given
        let announcementDeleted = AnnouncementDeleted()
        let useCase = DeleteAnnouncementUseCase(
            announcementRepository: announcementDeleted
        )
        
        // When
        try? await useCase.execute(announcement: announcementFixture.copy{ $0.state = .published })
        
        // Then
        #expect(announcementDeleted.deleteAnnouncementCalled)
    }
    
    @Test
    func deleteAnnouncementUseCase_should_delete_announcement_locally_when_state_is_not_published() async {
        // Given
        let announcementDeletedLocally = AnnouncementDeletedLocally()
        let useCase = DeleteAnnouncementUseCase(
            announcementRepository: announcementDeletedLocally
        )
        
        // When
        try? await useCase.execute(announcement: announcementFixture.copy{ $0.state = .draft })

        // Then
        #expect(announcementDeletedLocally.deleteLocalAnnouncementCalled)
    }
}

private class AnnouncementDeleted: MockAnnouncementRepository {
    private(set) var deleteAnnouncementCalled = false
    
    override func deleteAnnouncement(announcementId: String, authorId: String) async throws {
        deleteAnnouncementCalled = true
    }
}

private class AnnouncementDeletedLocally: MockAnnouncementRepository {
    private(set) var deleteLocalAnnouncementCalled = false
    
    override func deleteLocalAnnouncement(announcementId: String) {
        deleteLocalAnnouncementCalled = true
    }
}
