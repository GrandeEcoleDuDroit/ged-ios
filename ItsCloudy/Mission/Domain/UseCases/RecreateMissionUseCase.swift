import Foundation

class RecreateMissionUseCase {
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
    
    func execute(mission: Mission) async {
        let task = Task {
            var fileData: FileData?
            
            if let imagePath = mission.state.resolveImagePath(),
               let imageData = try? await imageRepository.getLocalImage(imagePath: imagePath) {
                fileData = FileData(path: imagePath, data: imageData)
            }
            
            do {
                try await missionRepository.createMission(
                    mission: mission.copy { $0.state = .publishing(imagePath: fileData?.path) },
                    fileData: fileData
                )
                
                try await missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .published(imageUrl: fileData?.path) }
                )
                
                await missionTaskQueue.removeTask(for: mission.id)
                
                if let imagePath = fileData?.path {
                    try? await imageRepository.deleteLocalImage(imagePath: imagePath)
                }
            } catch {
                try? await missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .error(imagePath: fileData?.path) }
                )
                await missionTaskQueue.removeTask(for: mission.id)
            }
        }
        
        await missionTaskQueue.addTask(task, for: mission.id)
    }
}
