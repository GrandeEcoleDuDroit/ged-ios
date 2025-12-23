import Foundation

class ResendMissionUseCase {
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
    
    func execute(mission: Mission) async {
        let task = Task {
            let imagePath: String? = switch mission.state {
                case let .publishing(imagePath: imagePath): imagePath
                case let .error(imagePath: imagePath): imagePath
                default: nil
            }
            
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
                
                await missionTaskReferences.removeTaskReference(for: mission.id)
                
                if let imagePath {
                    try? await imageRepository.deleteLocalImage(imagePath: imagePath)
                }
            } catch {
                try? await missionRepository.updateLocalMission(
                    mission: mission.copy { $0.state = .error(imagePath: imagePath) }
                )
                await missionTaskReferences.removeTaskReference(for: mission.id)
            }
        }
        
        await missionTaskReferences.addTaskReference(task, for: mission.id)
    }
}
