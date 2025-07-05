import Testing

@testable import GrandeEcoleDuDroit

class DeleteAnnouncementUseCaseTest {
    @Test
    func deleteAnnouncementUseCase_should_throw_network_error_when_no_internet_connection() async throws {
        // Given
        let useCase = DeleteAnnouncementUseCase(
            announcementRepository: MockAnnouncementRepository(),
            networkMonitor: MockNetworkMonitor()
        )
        
        // When
        let result = await #expect(throws: NetworkError.noInternetConnection) {
            try await useCase.execute(announcement: announcementFixture)
        }
        
        // Then
        #expect(result == NetworkError.noInternetConnection)
    }
}
