import Testing

@testable import GrandeEcoleDuDroit

class ResendAnnouncementUseCaseTest {
    @Test
    func resendAnnouncementUseCase_should_throw_network_error_when_no_internet_connection() async throws {
        // Given
        let useCase = ResendAnnouncementUseCase(
            announcementRepository: MockAnnouncementRepository(),
            networkMonitor: MockNetworkMonitor()
        )
        
        // When
        let result = await #expect(throws: RequestError.noInternetConnection) {
            try await useCase.execute(announcement: announcementFixture)
        }
        
        // Then
        #expect(result == RequestError.noInternetConnection)
    }
}
