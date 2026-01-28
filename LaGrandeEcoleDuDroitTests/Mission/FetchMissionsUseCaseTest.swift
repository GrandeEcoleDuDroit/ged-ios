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
            deleteMissionUseCase: TestDeleteMissionUseCase(),
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
        let testDeleteMissionUseCase = TestDeleteMissionUseCase()
        let useCase = FetchMissionsUseCase(
            missionRepository: testMissionsRepository,
            deleteMissionUseCase: testDeleteMissionUseCase,
            upsertMissionUseCase: MockUpsertMissionUseCase()
        )
        
        // When
        try? await useCase.execute()
        
        // Then
        #expect(testDeleteMissionUseCase.deletedMissionIds == currentMissions.map { $0.id })
    }
}

private class TestMissionRepository: MockMissionRepository {
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
    
    override func getRemoteMissions() async throws -> [Mission] {
        givenRemoteMissions
    }
}

private class TestDeleteMissionUseCase: MockDeleteMissionUseCase {
    private(set) var deletedMissionIds: [String] = []
    
    override func execute(mission: Mission) async throws {
        deletedMissionIds.append(mission.id)
    }
}

private class TestUpsertMissionUseCase: MockUpsertMissionUseCase {
    private(set) var upsertedMissionIds: [String] = []
    
    override func execute(mission: Mission) async throws {
        upsertedMissionIds.append(mission.id)
    }
}
