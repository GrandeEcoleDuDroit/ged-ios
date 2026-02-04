import Testing
import Combine

@testable import GrandeEcoleDuDroit

class FetchMissionsUseCaseTest {
    @Test
    func fetchMissionsUseCase_should_upsert_new_remote_missions() async {
        // Given
        let remoteMissions = missionsFixture
        let testMissionsRepository = TestMissionRepository(
            givenCurrentMissions: [],
            givenRemoteMissions: remoteMissions
        )
        let testUpsertMissionUseCase = TestUpsertMissionUseCase()
        let useCase = FetchMissionsUseCase(
            missionRepository: testMissionsRepository,
            upsertMissionUseCase: testUpsertMissionUseCase
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(testUpsertMissionUseCase.upsertedMissionIds == remoteMissions.map { $0.id })
    }
    
    @Test
    func fetchMissionsUseCase_should_delete_missions_not_present_in_remote() async {
        // Given
        let currentMissions = missionsFixture
        let testMissionsRepository = TestMissionRepository(
            givenCurrentMissions: currentMissions,
            givenRemoteMissions: []
        )
        let useCase = FetchMissionsUseCase(
            missionRepository: testMissionsRepository,
            upsertMissionUseCase: MockUpsertMissionUseCase()
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(testMissionsRepository.deletedMissionIds == currentMissions.map { $0.id })
    }
}

private class TestMissionRepository: MockMissionRepository {
    private let givenCurrentMissions: [Mission]
    private let givenRemoteMissions: [Mission]
    private(set) var deletedMissionIds: [String] = []
    
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
    
    override func getRemoteMissions() async throws -> [Mission] {
        givenRemoteMissions
    }
    
    override func deleteLocalMission(missionId: String) async throws {
        deletedMissionIds.append(missionId)
    }
}

private class TestUpsertMissionUseCase: MockUpsertMissionUseCase {
    private(set) var upsertedMissionIds: [String] = []
    
    override func execute(mission: Mission) async throws {
        upsertedMissionIds.append(mission.id)
    }
}
