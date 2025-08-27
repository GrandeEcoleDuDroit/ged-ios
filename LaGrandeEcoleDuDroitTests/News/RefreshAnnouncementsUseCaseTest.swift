import Testing

@testable import GrandeEcoleDuDroit

class RefreshAnnouncementsUseCaseTest {
    @Test
    func refreshAnnouncementsUseCase_should_throw_network_error_when_no_internet_connection() async throws {
        // Given
        let useCase = RefreshAnnouncementsUseCase(
            announcementRepository: MockAnnouncementRepository(),
            networkMonitor: MockNetworkMonitor()
        )
        
        // When
        let result = await #expect(throws: RequestError.noInternetConnection) {
            try await useCase.execute()
        }
        
        // Then
        #expect(result == RequestError.noInternetConnection)
    }
}
