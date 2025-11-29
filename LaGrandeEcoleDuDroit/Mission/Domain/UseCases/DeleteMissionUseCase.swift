class DeleteMissionUseCase {
    private let missionRepository: MissionRepository
    private let imageRepository: ImageRepository
    
    init(
        missionRepository: MissionRepository,
        imageRepository: ImageRepository
    ) {
        self.missionRepository = missionRepository
        self.imageRepository = imageRepository
    }
    
    func execute(mission: Mission) async throws {
        switch mission.state {
            case .draft: try await missionRepository.deleteLocalMission(missionId: mission.id)
                
            case let .publishing(imagePath):
                try await missionRepository.deleteLocalMission(missionId: mission.id)
                if let imagePath {
                    try await imageRepository.deleteLocalImage(imagePath: imagePath)
                }
                
            case let .published(imageUrl):
                try await missionRepository.deleteMission(mission: mission, imageUrl: imageUrl)
            
            case let .error(imagePath):
                try await missionRepository.deleteLocalMission(missionId: mission.id)
                if let imagePath {
                    try await imageRepository.deleteLocalImage(imagePath: imagePath)
                }
        }
    }
}
