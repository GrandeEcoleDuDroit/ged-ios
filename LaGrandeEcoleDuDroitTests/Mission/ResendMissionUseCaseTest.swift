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
        let missionTaskReferences = MissionTaskQueue()

        // When
        let useCase = ResendMissionUseCase(
            missionRepository: missionRepositoryTest,
            imageRepository: MockImageRepository(),
            missionTaskReferences: missionTaskReferences
        )
        await useCase.execute(mission: mission)
        await missionTaskReferences.tasks[mission.id]?.value

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
        let missionTaskReferences = MissionTaskQueue()

        // When
        let useCase = ResendMissionUseCase(
            missionRepository: missionRepositoryTest,
            imageRepository: MockImageRepository(),
            missionTaskReferences: missionTaskReferences
        )
        await useCase.execute(mission: mission)
        await missionTaskReferences.tasks[mission.id]?.value
        
        // Then
        #expect(missionRepositoryTest.updatedMissionState?.type == .publishedType)
        
        let pathResult: String? = if case let .published(path) = missionRepositoryTest.updatedMissionState {
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
        let missionTaskReferences = MissionTaskQueue()

        // When
        let useCase = ResendMissionUseCase(
            missionRepository: missionRepositoryTest,
            imageRepository: imageRepositoryTest,
            missionTaskReferences: missionTaskReferences
        )
        await useCase.execute(mission: mission)
        await missionTaskReferences.tasks[mission.id]?.value

        // Then
        #expect(missionRepositoryTest.transmittedImageData == imageData)
    }
    
    @Test
    func resendMissionUseCase_should_update_state_to_error_when_exception_occured() async {
        // Given
        let imagePath = "/path/to/image"
        let mission = missionFixture.copy { $0.state = .error(imagePath: imagePath) }
        let createMissionException = CreateMissionThrowsException()
        let missionTaskReferences = MissionTaskQueue()
        
        // When
        let useCase = ResendMissionUseCase(
            missionRepository: createMissionException,
            imageRepository: MockImageRepository(),
            missionTaskReferences: missionTaskReferences
        )
        await useCase.execute(mission: mission)
        await missionTaskReferences.tasks[mission.id]?.value
        
        // Then
        #expect(createMissionException.updatedMissionState?.type == .errorType)
        let pathResult: String? = if case let .error(path) = createMissionException.updatedMissionState {
            path
        } else {
            nil
        }
        #expect(pathResult == imagePath)
    }
}

private class MissionRepositoryTest: MockMissionRepository {
    var createdMissionState: Mission.MissionState?
    var updatedMissionState: Mission.MissionState?
    var transmittedImageData: Data?
    
    override func createMission(mission: Mission, imageData: Data?) async throws {
        createdMissionState = mission.state
        transmittedImageData = imageData
    }
    
    override func updateLocalMission(mission: Mission) async throws {
        updatedMissionState = mission.state
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
    var updatedMissionState: Mission.MissionState?

    override func createMission(mission: Mission, imageData: Data?) async throws {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
    
    override func updateLocalMission(mission: Mission) async throws {
        updatedMissionState = mission.state
    }
}
