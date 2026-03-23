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
            var fileData: FileData?
            
            if let imageData, let imageExtension = imageData.imageExtension() {
                let fileName = MissionUtils.Image.generateFileName(missionId: mission.id) + "." + imageExtension
                let path = MissionUtils.Image.getRelativePath(fileName: fileName)
                fileData = FileData(path: path, data: imageData)
                try? await self.imageRepository.createLocalImage(imageData: imageData, imagePath: path)
            }
            
            do {
                try await self.missionRepository.createMission(
                    mission: mission.copy { $0.state = .publishing(imagePath: fileData?.path) },
                    fileData: fileData
                )
                
                try await self.missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .published(imageUrl: fileData?.path) }
                )
                
                await self.missionTaskQueue.removeTask(for: mission.id)
                
                if let path = fileData?.path {
                    try await self.imageRepository.deleteLocalImage(imagePath: path)
                }
            } catch {
                try? await self.missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .error(imagePath: fileData?.path) }
                )
                await self.missionTaskQueue.removeTask(for: mission.id)
            }
        }
    
        await self.missionTaskQueue.addTask(task, for: mission.id)
    }
}
