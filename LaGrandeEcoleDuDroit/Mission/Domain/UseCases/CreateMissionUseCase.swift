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
        var imageFileName: String?
        var imagePath: String?
        
        if let data = imageData, let imageExtension = data.imageExtension() {
            imageFileName = "\(MissionUtils.formatImageFileName(missionId: mission.id)).\(imageExtension)"
            imagePath = try? await imageRepository.createLocalImage(
                imageData: data,
                folderName: MissionUtils.folderName,
                fileName: imageFileName!
            )
        }
        
        do {
            try await missionRepository.createMission(
                mission: mission.copy { $0.state = .publishing(imagePath: imagePath) },
                imageData: imageData
            )
            
            try await missionRepository.upsertLocalMission(
                mission: mission.copy { $0.state = .published(imageUrl: imageFileName) }
            )
            
            if let imageFileName {
                try await imageRepository.deleteLocalImage(folderName: MissionUtils.folderName, fileName: imageFileName)
            }
        } catch {
            try? await missionRepository.upsertLocalMission(
                mission: mission.copy { $0.state = .error(imagePath: imagePath) }
            )
        }
    }
}
