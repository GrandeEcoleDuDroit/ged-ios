import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class RefreshMissionUseCaseTest {
    @Test
    func refreshMissionsUseCase_should_fetch_mission_when_debounce_superior_than_10_seconds() async {
        // Given
        let missionSyncronized = SyncronizedMission()
        let useCase = RefreshMissionsUseCase(
            fetchMissionsUseCase: missionSyncronized
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(missionSyncronized.synchronizedMission)
    }
    
    @Test
    func refreshMissionsUseCase_should_not_fetch_mission_when_debounce_inferior_than_10_seconds() async {
        // Given
        let syncronizedMission = SyncronizedMission()
        let useCase = RefreshMissionsUseCase(
            fetchMissionsUseCase: syncronizedMission
        )
        
        // When
        try? await useCase.execute()
        syncronizedMission.synchronizedMission = false
        try? await useCase.execute()
        
        // Then
        #expect(!syncronizedMission.synchronizedMission)
    }
}

private class SyncronizedMission: MockSynchronizeMissionsUseCase {
    var synchronizedMission: Bool = false
    
    override func execute() async throws {
        synchronizedMission = true
    }
}
