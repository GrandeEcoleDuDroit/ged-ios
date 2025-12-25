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
    
    func execute(mission: Mission, imageData: Data?) async throws {
        var missionToUpdate = mission
        
        if let imageData, let imageExtension = imageData.imageExtension() {
            let fileName = "\(MissionUtils.Image.generateFileName(missionId: mission.id)).\(imageExtension)"
            missionToUpdate = mission.copy { $0.state = .published(imageUrl: fileName) }
        }
        
        try await missionRepository.updateMission(mission: missionToUpdate, imageData: imageData)
    }
}
