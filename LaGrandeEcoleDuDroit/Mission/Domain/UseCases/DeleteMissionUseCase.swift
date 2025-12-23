class DeleteMissionUseCase {
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
    
    func execute(mission: Mission) async throws {
        switch mission.state {
            case .draft: try await missionRepository.deleteLocalMission(missionId: mission.id)
                
            case let .publishing(imagePath):
                await missionTaskReferences.tasks[mission.id]?.cancel()
                await missionTaskReferences.removeTaskReference(for: mission.id)
                
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
