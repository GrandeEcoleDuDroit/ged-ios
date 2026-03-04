import Foundation

class CreateMissionUseCase {
    private let missionRepository: MissionRepository
    private let imageRepository: ImageRepository
    private let missionTaskQueue: MissionTaskQueue
    
    init(
        missionRepository: MissionRepository,
        imageRepository: ImageRepository,
        missionTaskQueue: MissionTaskQueue
    ) {
        self.missionRepository = missionRepository
        self.imageRepository = imageRepository
        self.missionTaskQueue = missionTaskQueue
    }
    
    func execute(mission: Mission, imageData: Data?) async {
        let task = Task {
            var imagePath: String?
            
            if let imageData, let imageExtension = imageData.imageExtension() {
                let fileName = MissionUtils.Image.generateFileName(missionId: mission.id) + "." + imageExtension
                imagePath = MissionUtils.Image.getRelativePath(fileName: fileName)
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
                
                await self.missionTaskQueue.removeTask(for: mission.id)
                
                if let imagePath {
                    try await self.imageRepository.deleteLocalImage(imagePath: imagePath)
                }
            } catch {
                try? await self.missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .error(imagePath: imagePath) }
                )
                await self.missionTaskQueue.removeTask(for: mission.id)
            }
        }
    
        await self.missionTaskQueue.addTask(task, for: mission.id)
    }
}
