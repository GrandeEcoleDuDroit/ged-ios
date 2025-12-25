import Testing

@testable import GrandeEcoleDuDroit

class DeleteAnnouncementUseCaseTest {
    @Test
    func deleteAnnouncementUseCase_should_delete_announcement_when_state_is_published() async {
        // Given
        let announcement = announcementFixture
        let announcementDeleted = AnnouncementDeleted()
        let announcementTaskReferences = AnnouncementTaskQueue()
        let useCase = DeleteAnnouncementUseCase(
            announcementRepository: announcementDeleted,
            announcementTaskReferences: announcementTaskReferences
        )
        
        // When
        try? await useCase.execute(announcement: announcement.copy{ $0.state = .published })
        await announcementTaskReferences.tasks[announcement.id]?.value
        
        // Then
        #expect(announcementDeleted.deleteAnnouncementCalled)
    }
    
    @Test
    func deleteAnnouncementUseCase_should_delete_announcement_locally_when_state_is_not_published() async {
        // Given
        let announcement = announcementFixture
        let announcementDeletedLocally = AnnouncementDeletedLocally()
        let announcementTaskReferences = AnnouncementTaskQueue()
        let useCase = DeleteAnnouncementUseCase(
            announcementRepository: announcementDeletedLocally,
            announcementTaskReferences: announcementTaskReferences
        )
        
        // When
        try? await useCase.execute(announcement: announcement.copy{ $0.state = .draft })
        await announcementTaskReferences.tasks[announcement.id]?.value
        
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
