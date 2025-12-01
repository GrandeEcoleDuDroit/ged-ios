import Foundation

class CreateMissionUseCase {
    private let missionRepository: MissionRepository
    private let imageRepository: ImageRepository
    
    init(
        missionRepository: MissionRepository,
        imageRepository: ImageRepository
    ) {
        self.missionRepository = missionRepository
        self.imageRepository = imageRepository
    }
    
    func execute(mission: Mission, imageData: Data?) async {
        var imagePath: String?
        
        if let imageData, let imageExtension = imageData.imageExtension() {
            let fileName = MissionUtils.ImageFile.generateFileName(missionId: mission.id) + "." + imageExtension
            imagePath = MissionUtils.ImageFile.relativePath(fileName: fileName)
            try? await imageRepository.createLocalImage(imageData: imageData, imagePath: imagePath!)
        }
        
        do {
            try await missionRepository.createMission(
                mission: mission.copy { $0.state = .publishing(imagePath: imagePath) },
                imageData: imageData
            )
            
            try await missionRepository.upsertLocalMission(
                mission: mission.copy { $0.state = .published(imageUrl: imagePath) }
            )
            
            if let imagePath {
                try await imageRepository.deleteLocalImage(imagePath: imagePath)
            }
        } catch {
            try? await missionRepository.upsertLocalMission(
                mission: mission.copy { $0.state = .error(imagePath: imagePath) }
            )
        }
    }
}
