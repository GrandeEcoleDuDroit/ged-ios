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
            let imagePath = mission.state.getImagePath()
            let imageData: Data? = if let imagePath {
                try? await imageRepository.getLocalImage(imagePath: imagePath)
            } else {
                nil
            }
            
            do {
                try await missionRepository.createMission(
                    mission: mission.copy { $0.state = .publishing(imagePath: imagePath) },
                    imageData: imageData
                )
                
                try await missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .published(imageUrl: imagePath) }
                )
                
                await missionTaskQueue.removeTask(for: mission.id)
                
                if let imagePath {
                    try? await imageRepository.deleteLocalImage(imagePath: imagePath)
                }
            } catch {
                try? await missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .error(imagePath: imagePath) }
                )
                await missionTaskQueue.removeTask(for: mission.id)
            }
        }
        
        await missionTaskQueue.addTask(task, for: mission.id)
    }
}
