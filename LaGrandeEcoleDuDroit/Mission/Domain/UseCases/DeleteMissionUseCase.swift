class DeleteMissionUseCase {
    private let missionRepository: MissionRepository
    private let imageRepository: ImageRepository
    private let missionTaskReferences: MissionTaskQueue

    init(
        missionRepository: MissionRepository,
        imageRepository: ImageRepository,
        missionTaskReferences: MissionTaskQueue
    ) {
        self.missionRepository = missionRepository
        self.imageRepository = imageRepository
        self.missionTaskReferences = missionTaskReferences
    }
    
    func execute(mission: Mission) async throws {
        switch mission.state {
            case .draft: try await missionRepository.deleteLocalMission(missionId: mission.id)
                
            case let .publishing(imagePath):
                await missionTaskReferences.cancelTask(for: mission.id)
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
