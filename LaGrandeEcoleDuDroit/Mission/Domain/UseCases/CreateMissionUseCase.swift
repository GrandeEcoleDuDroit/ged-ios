import Foundation

class CreateMissionUseCase {
    private let missionRepository: MissionRepository
    private let imageRepository: ImageRepository
    private let missionTaskReferences: MissionTaskReferences
    
    init(
        missionRepository: MissionRepository,
        imageRepository: ImageRepository,
        missionTaskReferences: MissionTaskReferences
    ) {
        self.missionRepository = missionRepository
        self.imageRepository = imageRepository
        self.missionTaskReferences = missionTaskReferences
    }
    
    func execute(mission: Mission, imageData: Data?) async {
        let task = Task {
            var imagePath: String?
            
            if let imageData, let imageExtension = imageData.imageExtension() {
                let fileName = MissionUtils.ImageFile.generateFileName(missionId: mission.id) + "." + imageExtension
                imagePath = MissionUtils.ImageFile.relativePath(fileName: fileName)
                try? await self.imageRepository.createLocalImage(imageData: imageData, imagePath: imagePath!)
            }
            
            do {
                try await self.missionRepository.createMission(
                    mission: mission.copy { $0.state = .publishing(imagePath: imagePath) },
                    imageData: imageData
                )
                
                try await self.missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .published(imageUrl: imagePath) }
                )
                
                await self.missionTaskReferences.removeTaskReference(for: mission.id)
                
                if let imagePath {
                    try await self.imageRepository.deleteLocalImage(imagePath: imagePath)
                }
            } catch {
                try? await self.missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .error(imagePath: imagePath) }
                )
                await self.missionTaskReferences.removeTaskReference(for: mission.id)
            }
        }
    
        await self.missionTaskReferences.addTaskReference(task, for: mission.id)
    }
}
