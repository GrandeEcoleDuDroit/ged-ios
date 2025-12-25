import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class UpdateMissionUseCaseTest {
    @Test
    func updateMissionUseCase_should_update_mission() async {
        // Given
        let missionRepositoryTest = MissionRepositoryTest()
        let useCase = UpdateMissionUseCase(
            missionRepository: missionRepositoryTest,
            imageRepository: MockImageRepository()
        )
        
        // When
        try? await useCase.execute(
            mission: missionFixture,
            imageData: nil
        )
        
        // Then
        #expect(missionRepositoryTest.missionUpdated)
    }
    
    @Test
    func updateMissionUseCase_should_set_new_path_in_mission_state_when_image_data_is_not_null() async {
        // Given
        let missionRepositoryTest = MissionRepositoryTest()
        let useCase = UpdateMissionUseCase(
            missionRepository: missionRepositoryTest,
            imageRepository: MockImageRepository()
        )
        let oldUrl = "url/oldPath"
        let mission = missionFixture.copy { $0.state = .published(imageUrl: oldUrl) }
        
        // When
        try? await useCase.execute(
            mission: mission,
            imageData: pngImageDataFixture
        )
        
        // Then
        #expect(missionRepositoryTest.updatedMissionState?.type == .publishedType)
        var pathUpdated = false
        if case let .published(imagePath) = missionRepositoryTest.updatedMissionState {
            let fileName = MissionUtils.Image.getFileName(uri: mission.state.imageReference)!
            let oldPath = MissionUtils.Image.getRelativePath(fileName: fileName)
            pathUpdated = imagePath != oldPath
        }
        #expect(pathUpdated)
    }
}

private class MissionRepositoryTest: MockMissionRepository {
    var missionUpdated: Bool = false
    var updatedMissionState: Mission.MissionState?
    
    override func updateMission(mission: Mission, imageData: Data?) async throws {
        missionUpdated = true
        updatedMissionState = mission.state
    }
}
