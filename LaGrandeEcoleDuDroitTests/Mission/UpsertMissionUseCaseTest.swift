import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class UpsertMissionUseCaseTest {
    @Test
    func upsertMissionUseCase_should_upsert_mission() async {
        // Given
        let testMissionRepository = TestMissionRepository()
        let useCase = UpsertMissionUseCase(
            missionRepository: testMissionRepository,
            imageRepository: MockImageRepository(),
        )
        
        // When
        try? await useCase.execute(mission: missionFixture)
        
        // Then
        #expect(testMissionRepository.upsertedMission == missionFixture)
    }
    
    @Test
    func upsertMissionUseCase_should_delete_previous_local_image_when_present() async {
        // Given
        let imagePath = "path"
        let mission = missionFixture.copy { $0.state = .publishing(imagePath: imagePath) }
        let testMissionRepository = TestMissionRepository(givenMission: mission)
        let testImageRepository = TestImageRepository()
        let useCase = UpsertMissionUseCase(
            missionRepository: testMissionRepository,
            imageRepository: testImageRepository
        )
        
        // When
        try? await useCase.execute(mission: mission)
        
        // Then
        #expect(testImageRepository.deletedImagePath == imagePath)
    }
    
    private class TestMissionRepository: MockMissionRepository {
        var upsertedMission: Mission? = nil
        let givenMission: Mission
        
        init(givenMission: Mission = missionFixture) {
            self.givenMission = givenMission
        }
        
        override func upsertLocalMission(mission: Mission) async throws {
            upsertedMission = mission
        }
        
        override func getLocalMission(missionId: String) async throws -> Mission? {
            givenMission
        }
    }
    
    private class TestImageRepository: MockImageRepository {
        var deletedImagePath: String? = nil
        
        override func deleteLocalImage(imagePath: String) async throws {
            deletedImagePath = imagePath
        }
    }
}
