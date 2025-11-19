import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class RefreshMissionUseCaseTest {
    @Test
    func refreshMissionsUseCase_should_synchronize_mission_when_debounce_superior_than_10_seconds() async {
        // Given
        let missionSyncronized = MissionSyncronized()
        let useCase = RefreshMissionsUseCase(
            synchronizeMissionsUseCase: missionSyncronized
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(missionSyncronized.missionSynchronized)
    }
    
    @Test
    func refreshMissionsUseCase_should_not_synchronize_mission_when_debounce_inferior_than_10_seconds() async {
        // Given
        let missionSyncronized = MissionSyncronized()
        let useCase = RefreshMissionsUseCase(
            synchronizeMissionsUseCase: missionSyncronized
        )
        
        // When
        try? await useCase.execute()
        missionSyncronized.missionSynchronized = false
        try? await useCase.execute()
        
        // Then
        #expect(!missionSyncronized.missionSynchronized)
    }
}

private class MissionSyncronized: MockSynchronizeMissionsUseCase {
    var missionSynchronized: Bool = false
    
    override func execute() async throws {
        missionSynchronized = true
    }
}
