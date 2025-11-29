import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class DeleteMissionUseCaseTest {
    @Test
    func deleteMissionUseCase_shoul_delete_local_mission_when_state_is_draft() async {
        // Given
        let mission = missionFixture.copy { $0.state = .draft }
        let missionRepository = MissionRepositoryTest(
            givenMission: mission
        )
        let useCase = DeleteMissionUseCase(
            missionRepository: missionRepository,
            imageRepository: MockImageRepository()
        )
        
        // When
        try? await useCase.execute(mission: mission)
        
        // Then
        #expect(missionRepository.localMissionDeleted)
    }
    
    @Test
    func deleteMissionUseCase_shoul_delete_local_mission_when_state_is_publishing() async {
        // Given
        let mission = missionFixture.copy { $0.state = .publishing() }
        let missionRepository = MissionRepositoryTest(
            givenMission: mission
        )
        let useCase = DeleteMissionUseCase(
            missionRepository: missionRepository,
            imageRepository: MockImageRepository()
        )
        
        // When
        try? await useCase.execute(mission: mission)
        
        // Then
        #expect(missionRepository.localMissionDeleted)
    }
    
    @Test
    func deleteMissionUseCase_shoul_delete_mission_when_state_is_published() async {
        // Given
        let mission = missionFixture.copy { $0.state = .published() }
        let missionRepository = MissionRepositoryTest(
            givenMission: mission
        )
        let useCase = DeleteMissionUseCase(
            missionRepository: missionRepository,
            imageRepository: MockImageRepository()
        )
        
        // When
        try? await useCase.execute(mission: mission)
        
        // Then
        #expect(missionRepository.missionDeleted)
    }
    
    @Test
    func deleteMissionUseCase_shoul_delete_mission_when_state_is_error() async {
        // Given
        let mission = missionFixture.copy { $0.state = .error() }
        let missionRepository = MissionRepositoryTest(
            givenMission: mission
        )
        let useCase = DeleteMissionUseCase(
            missionRepository: missionRepository,
            imageRepository: MockImageRepository()
        )
        
        // When
        try? await useCase.execute(mission: mission)
        
        // Then
        #expect(missionRepository.localMissionDeleted)
    }
}

private class MissionRepositoryTest: MockMissionRepository {
    let givenMission: Mission
    var localMissionDeleted: Bool = false
    var missionDeleted: Bool = false
    
    init(givenMission: Mission) {
        self.givenMission = givenMission
    }
    
    override func deleteLocalMission(missionId: String) async throws {
        localMissionDeleted = true
    }
    
    override func deleteMission(mission: Mission, imageUrl: String?) async throws {
        missionDeleted = true
    }
}
