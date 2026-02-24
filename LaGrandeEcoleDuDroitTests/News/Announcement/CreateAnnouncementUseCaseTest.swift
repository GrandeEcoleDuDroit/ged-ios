import Testing

@testable import GrandeEcoleDuDroit

class CreateAnnouncementUseCaseTest {
    @Test
    func createAnnouncementUseCase_should_set_announcement_state_to_pbulished() async throws {
        // Given
        let announcement = announcementFixture
        let announcementSetPublished = AnnouncementSetPublished()
        let announcementTaskQueue = AnnouncementTaskQueue()
        let useCase = CreateAnnouncementUseCase(
            announcementRepository: announcementSetPublished,
            announcementTaskQueue: announcementTaskQueue
        )
        
        // When
        await useCase.execute(announcement: announcement)
        await announcementTaskQueue.tasks[announcement.id]?.value

        // Then
        #expect(announcementSetPublished.announcementSetToPublished)
    }
    
    @Test
    func createAnnouncementUseCase_should_set_announcement_state_to_error_when_exception_thrown() async {
        // Given
        let announcement = announcementFixture
        let announcementSetError = AnnouncementSetError()
        let announcementTaskQueue = AnnouncementTaskQueue()
        let useCase = CreateAnnouncementUseCase(
            announcementRepository: announcementSetError,
            announcementTaskQueue: announcementTaskQueue
        )
        
        // When
        await useCase.execute(announcement: announcement)
        await announcementTaskQueue.tasks[announcement.id]?.value
        
        // Then
        #expect(announcementSetError.announcementSetToError)
    }
}

private class AnnouncementSetPublished: MockAnnouncementRepository {
    var announcementSetToPublished: Bool = false
    
    override func updateLocalAnnouncement(announcement: Announcement) async throws {
        announcementSetToPublished = announcement.state == .published
    }
}

private class AnnouncementSetError: MockAnnouncementRepository {
    var announcementSetToError: Bool = false
    
    override func updateLocalAnnouncement(announcement: Announcement) async throws{
        announcementSetToError = announcement.state == .error
    }
    
    override func createAnnouncement(announcement: Announcement) async throws {
        throw NetworkError.notConnectedToInternet
    }
}
