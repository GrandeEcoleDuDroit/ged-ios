import Foundation

class ResendMissionUseCase {
    private let missionRepository: MissionRepository
    private let imageRepository: ImageRepository
    
    init(
        missionRepository: MissionRepository,
        imageRepository: ImageRepository
    ) {
        self.missionRepository = missionRepository
        self.imageRepository = imageRepository
    }
    
    func execute(mission: Mission) async {
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
            
            try await missionRepository.upsertLocalMission(
                mission: mission.copy { $0.state = .published(imageUrl: imagePath) }
            )
            
            if let imagePath {
                try? await imageRepository.deleteLocalImage(imagePath: imagePath)
            }
        } catch {
            try? await missionRepository.upsertLocalMission(
                mission: mission.copy { $0.state = .error(imagePath: imagePath) }
            )
        }
    }
}
