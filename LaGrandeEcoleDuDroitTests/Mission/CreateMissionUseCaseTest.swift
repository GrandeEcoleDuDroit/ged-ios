import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

private let imagePath = "path"

class CreateMissionUseCaseTest {
    @Test
    func createMissionsUseCase_should_create_local_image_when_image_data_is_not_null() async {
        // Given
        let localImageCreated = LocalImageCreated()
        let useCase = CreateMissionUseCase(
            missionRepository: MockMissionRepository(),
            imageRepository: localImageCreated
        )
        
        // When
        await useCase.execute(mission: missionFixture, imageData: pngImageDataFixture)
        
        // Then
        #expect(localImageCreated.createLocalImageCalled)
    }
    
    @Test
    func createMissionsUseCase_should_create_mission_with_publishing_state_with_image_path() async {
        // Given
        let localImageCreated = LocalImageCreated()
        let getMissionState = GetMissionMissionState()
        let useCase = CreateMissionUseCase(
            missionRepository: getMissionState,
            imageRepository: localImageCreated
        )
        
        // When
        await useCase.execute(mission: missionFixture, imageData: pngImageDataFixture)
        
        // Then
        #expect(getMissionState.createdMissionState?.type == .publishingType)
        
        let pathResult: String? = if case let .publishing(imagePath) = getMissionState.createdMissionState {
            imagePath
        } else {
            nil
        }
        #expect(pathResult != nil)
    }
    
    @Test
    func createMissionsUseCase_should_upsert_mission_with_published_state_when_succeed()  async{
        // Given
        let getMissionState = GetMissionMissionState()
        let useCase = CreateMissionUseCase(
            missionRepository: getMissionState,
            imageRepository: MockImageRepository()
        )
        
        // When
        await useCase.execute(mission: missionFixture, imageData: nil)
        
        // Then
        #expect(getMissionState.upsertedMissionState?.type == .publishedType)
    }
    
    @Test
    func createMissionsUseCase_should_delete_created_local_image() async {
        // Given
        let localImageDeleted = LocalImageDeleted()
        let useCase = CreateMissionUseCase(
            missionRepository: MockMissionRepository(),
            imageRepository: localImageDeleted
        )
        
        // When
        await useCase.execute(mission: missionFixture, imageData: pngImageDataFixture)
        
        // Then
        #expect(localImageDeleted.deleteLocalImageCalled)
    }
    
    @Test
    func createMissionsUseCase_should_upsert_mission_with_error_state_and_image_path_when_exception_throwns() async {
        // Given
        let localImageCreated = LocalImageCreated()
        let createMissionException = CreateMissionThrowsException()
        let useCase = CreateMissionUseCase(
            missionRepository: createMissionException,
            imageRepository: localImageCreated
        )
        
        // When
        await useCase.execute(mission: missionFixture, imageData: pngImageDataFixture)

        // Then
        #expect(createMissionException.upsertedMissionState?.type == .errorType)
        
        let pathResult: String? = if case let .error(imagePath) = createMissionException.upsertedMissionState {
            imagePath
        } else {
            nil
        }
        #expect(pathResult != nil)
    }
}

private class LocalImageCreated: MockImageRepository {
    var createLocalImageCalled = false
    
    override func createLocalImage(imageData: Data, imagePath: String) async throws {
        createLocalImageCalled = true
    }
}

private class LocalImageDeleted: MockImageRepository {
    var deleteLocalImageCalled = false
    
    override func deleteLocalImage(imagePath: String) async throws {
        deleteLocalImageCalled = true
    }
}

private class GetMissionMissionState: MockMissionRepository {
    var createdMissionState: Mission.MissionState?
    var upsertedMissionState: Mission.MissionState?
    
    override func createMission(mission: Mission, imageData: Data?) async throws {
        createdMissionState = mission.state
    }
    
    override func upsertLocalMission(mission: Mission) async throws {
        upsertedMissionState = mission.state
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
