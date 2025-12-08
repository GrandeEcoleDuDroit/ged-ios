import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class ResendMissionUseCaseTest {
    @Test
    func resendMissionUseCase_should_create_mission_with_publishing_state_and_image_path() async {
        // Given
        let imagePath = "imagePath"
        let mission = missionFixture.copy { $0.state = .error(imagePath: imagePath) }
        let missionRepositoryTest = MissionRepositoryTest()
        
        // When
        let useCase = ResendMissionUseCase(
            missionRepository: missionRepositoryTest,
            imageRepository: MockImageRepository()
        )
        await useCase.execute(mission: mission)
        
        // Then
        #expect(missionRepositoryTest.createdMissionState?.type == .publishingType)
        let pathResult: String? = if case let .publishing(path) = missionRepositoryTest.createdMissionState {
            path
        } else {
            nil
        }
        #expect(pathResult == imagePath)
    }
    
    @Test
    func resendMissionUseCase_should_update_mission_state_to_published_with_image_path_when_success() async {
        // Given
        let imagePath = "imagePath"
        let mission = missionFixture.copy { $0.state = .error(imagePath: imagePath) }
        let missionRepositoryTest = MissionRepositoryTest()
        
        // When
        let useCase = ResendMissionUseCase(
            missionRepository: missionRepositoryTest,
            imageRepository: MockImageRepository()
        )
        await useCase.execute(mission: mission)
        
        // Then
        #expect(missionRepositoryTest.upsertedMissionState?.type == .publishedType)
        
        let pathResult: String? = if case let .published(path) = missionRepositoryTest.upsertedMissionState {
            path
        } else {
            nil
        }
        #expect(pathResult == imagePath)
    }
    
    @Test
    func resendMissionUseCase_should_pass_image_data_when_image_path_is_present() async {
        // Given
        let imagePath = "/path/to/image"
        let mission = missionFixture.copy { $0.state = .error(imagePath: imagePath) }
        let imageData = pngImageDataFixture
        let missionRepositoryTest = MissionRepositoryTest()
        let imageRepositoryTest = ImageRepositoryTest(givenImageData: imageData)
        
        // When
        let useCase = ResendMissionUseCase(
            missionRepository: missionRepositoryTest,
            imageRepository: imageRepositoryTest
        )
        await useCase.execute(mission: mission)
        
        // Then
        #expect(missionRepositoryTest.transmittedImageData == imageData)
    }
    
    @Test
    func resendMissionUseCase_should_update_state_to_error_when_exception_occured() async {
        // Given
        let imagePath = "/path/to/image"
        let mission = missionFixture.copy { $0.state = .error(imagePath: imagePath) }
        let createMissionException = CreateMissionThrowsException()
        
        // When
        let useCase = ResendMissionUseCase(
            missionRepository: createMissionException,
            imageRepository: MockImageRepository()
        )
        await useCase.execute(mission: mission)
        
        // Then
        #expect(createMissionException.upsertedMissionState?.type == .errorType)
        let pathResult: String? = if case let .error(path) = createMissionException.upsertedMissionState {
            path
        } else {
            nil
        }
        #expect(pathResult == imagePath)
    }
}

private class MissionRepositoryTest: MockMissionRepository {
    var createdMissionState: Mission.MissionState?
    var upsertedMissionState: Mission.MissionState?
    var transmittedImageData: Data?
    
    override func createMission(mission: Mission, imageData: Data?) async throws {
        createdMissionState = mission.state
        transmittedImageData = imageData
    }
    
    override func upsertLocalMission(mission: Mission) async throws {
        upsertedMissionState = mission.state
    }
}

private class ImageRepositoryTest: MockImageRepository {
    let givenImageData: Data
    
    init(givenImageData: Data) {
        self.givenImageData = givenImageData
    }

    override func getLocalImage(imagePath: String) async throws -> Data? {
        givenImageData
    }
}

private class CreateMissionThrowsException: MockMissionRepository {
    var upsertedMissionState: Mission.MissionState?

    override func createMission(mission: Mission, imageData: Data?) async throws {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
    
    override func upsertLocalMission(mission: Mission) async throws {
        upsertedMissionState = mission.state
    }
}
