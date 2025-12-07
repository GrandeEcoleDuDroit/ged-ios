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
            imageData: nil,
            previousMissionState: .draft
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
            imageData: pngImageDataFixture,
            previousMissionState: .draft
        )
        
        // Then
        #expect(missionRepositoryTest.updatedMissionState?.type == Mission.MissionState.MissionStateType.published)
        var newPath = false
        if case let .published(imagePath) = missionRepositoryTest.updatedMissionState {
            let oldPath = MissionUtils.ImageFile.getImagePathFromUrl(url: mission.state.imageReference)
            newPath = imagePath != oldPath
        }
        #expect(newPath)
    }
    
    @Test
    func updateMissionUseCase_should_delete_previous_image() async {
        // Given
        let imageRepositoryTest = ImageRepositoryTest()
        let useCase = UpdateMissionUseCase(
            missionRepository: MockMissionRepository(),
            imageRepository: imageRepositoryTest
        )
        let oldPath = "oldPath"
        let oldUrl = "url/\(oldPath)"
        
        // When
        try? await useCase.execute(
            mission: missionFixture,
            imageData: pngImageDataFixture,
            previousMissionState: .published(imageUrl: oldUrl)
        )
        
        // Then
        #expect(imageRepositoryTest.deletedImagePath != oldPath)
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

private class ImageRepositoryTest: MockImageRepository {
    var deletedImagePath: String?

    override func deleteRemoteImage(imagePath: String) async throws {
        deletedImagePath = imagePath
    }
}
