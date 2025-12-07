import Testing

@testable import GrandeEcoleDuDroit

class ResendAnnouncementUseCaseTest {
    @Test
    func resendAnnouncementUseCase_should_set_announcement_state_to_pbulished() async throws {
        // Given
        let announcementSetPublished = AnnouncementSetPublished()
        let useCase = ResendAnnouncementUseCase(
            announcementRepository: announcementSetPublished
        )
        
        // When
        await useCase.execute(announcement: announcementFixture)
        
        // Then
        #expect(announcementSetPublished.announcementSetToPublished)
    }
    
    @Test
    func resendAnnouncementUseCase_should_set_announcement_state_to_error_when_exception_thrown() async {
        // Given
        let announcementSetError = AnnouncementSetError()
        let useCase = ResendAnnouncementUseCase(
            announcementRepository: announcementSetError
        )
        
        // When
        await useCase.execute(announcement: announcementFixture)
        
        // Then
        #expect(announcementSetError.announcementSetToError)
    }
}

private class AnnouncementSetPublished: MockAnnouncementRepository {
    var announcementSetToPublished: Bool = false
    
    override func upsertLocalAnnouncement(announcement: Announcement) async throws {
        announcementSetToPublished = announcement.state == .published
    }
}

private class AnnouncementSetError: MockAnnouncementRepository {
    var announcementSetToError: Bool = false
    
    override func upsertLocalAnnouncement(announcement: Announcement) async throws {
        announcementSetToError = announcement.state == .error
    }
    
    override func createAnnouncement(announcement: Announcement) async throws {
        throw NetworkError.noInternetConnection
    }
}
