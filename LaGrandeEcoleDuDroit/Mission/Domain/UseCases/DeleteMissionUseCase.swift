class DeleteMissionUseCase {
    private let missionRepository: MissionRepository
    private let imageRepository: ImageRepository
    private let missionJobReferences: MissionJobReferences

    init(
        missionRepository: MissionRepository,
        imageRepository: ImageRepository,
        missionJobReferences: MissionJobReferences
    ) {
        self.missionRepository = missionRepository
        self.imageRepository = imageRepository
        self.missionJobReferences = missionJobReferences
    }
    
    func execute(mission: Mission) async throws {
        switch mission.state {
            case .draft: try await missionRepository.deleteLocalMission(missionId: mission.id)
                
            case let .publishing(imagePath):
                await missionJobReferences.tasks[mission.id]?.cancel()
                await missionJobReferences.removeTaskReference(for: mission.id)
                
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
