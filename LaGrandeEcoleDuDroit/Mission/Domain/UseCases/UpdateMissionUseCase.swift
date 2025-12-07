import Foundation

class UpdateMissionUseCase {
    private let missionRepository: MissionRepository
    private let imageRepository: ImageRepository
    
    init(
        missionRepository: MissionRepository,
        imageRepository: ImageRepository
    ) {
        self.missionRepository = missionRepository
        self.imageRepository = imageRepository
    }
    
    func execute(mission: Mission, imageData: Data?, previousMissionState: Mission.MissionState) async throws {
        var newImagePath: String?
        
        if let imageData, let imageExtension = imageData.imageExtension() {
            let fileName = "\(MissionUtils.ImageFile.generateFileName(missionId: mission.id)).\(imageExtension)"
            newImagePath = MissionUtils.ImageFile.relativePath(fileName: fileName)
        }
        
        let missionToUpdate = if let newImagePath {
            mission.copy { $0.state = .published(imageUrl: newImagePath) }
        } else {
            mission
        }
        
        try await missionRepository.updateMission(mission: missionToUpdate, imageData: imageData)
        try? await deletePreviousImage(missionState: missionToUpdate.state, previousMissionState: previousMissionState)
    }
    
    private func deletePreviousImage(missionState: Mission.MissionState, previousMissionState: Mission.MissionState) async throws {
        let previousImageUrl: String? = if
            previousMissionState.imageReference != missionState.imageReference,
            case let .published(url) = previousMissionState
        {
            url
        } else {
            nil
        }
        
        if let previousImagePath = MissionUtils.ImageFile.getImagePathFromUrl(url: previousImageUrl) {
            try await imageRepository.deleteRemoteImage(imagePath: previousImagePath)
        }
    }
}
