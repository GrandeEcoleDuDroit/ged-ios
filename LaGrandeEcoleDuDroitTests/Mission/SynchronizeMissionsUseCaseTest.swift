import Testing
import Combine

@testable import GrandeEcoleDuDroit

class SynchronizeMissionsUseCaseTest {
    @Test
    func fetchMissionsUseCase_should_upsert_new_remote_missions() async {
        // Given
        let remoteMissions = missionsFixture
        let missionsUpserted = MissionsUpserted(
            givenCurrentMissions: [],
            givenRemoteMissions: remoteMissions
        )
        let useCase = FetchMissionsUseCase(
            missionRepository: missionsUpserted
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(missionsUpserted.missionsUpserted == remoteMissions)
    }
    
    @Test
    func fetchMissionsUseCase_should_delete_missions_not_present_in_remote() async {
        // Given
        let currentMissions = missionsFixture
        let missionsDeleted = MissionsDeleted(
            givenCurrentMissions: currentMissions,
            givenRemoteMissions: []
        )
        let useCase = FetchMissionsUseCase(
            missionRepository: missionsDeleted
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(missionsDeleted.missionDeletedIds == currentMissions.map { $0.id })
    }
}

private class MissionsDeleted: MockMissionRepository {
    var missionDeletedIds: [String] = []
    private let givenCurrentMissions: [Mission]
    private let givenRemoteMissions: [Mission]
    
    init(
        givenCurrentMissions: [Mission],
        givenRemoteMissions: [Mission]
    ) {
        self.givenCurrentMissions = givenCurrentMissions
        self.givenRemoteMissions = givenRemoteMissions
    }
    
    override var currentMissions: [Mission] {
        givenCurrentMissions
    }
    
    override func deleteLocalMission(missionId: String) async throws {
        missionDeletedIds.append(missionId)
    }
    
    override func getRemoteMissions() async throws -> [Mission] {
        givenRemoteMissions
    }
}

private class MissionsUpserted: MockMissionRepository {
    var missionsUpserted: [Mission] = []
    private let givenCurrentMissions: [Mission]
    private let givenRemoteMissions: [Mission]
    
    init(
        givenCurrentMissions: [Mission],
        givenRemoteMissions: [Mission]
    ) {
        self.givenCurrentMissions = givenCurrentMissions
        self.givenRemoteMissions = givenRemoteMissions
    }
    
    override var currentMissions: [Mission] {
        givenCurrentMissions
    }
    
    override func upsertLocalMission(mission: Mission) async throws {
        missionsUpserted.append(mission)
    }
    
    override func getRemoteMissions() async throws -> [Mission] {
        givenRemoteMissions
    }
}
