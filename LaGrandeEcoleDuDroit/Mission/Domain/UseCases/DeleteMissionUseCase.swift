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
                
            case let .publishing(imageFileName):
                try await missionRepository.deleteLocalMission(missionId: mission.id)
                if let imageFileName {
                    try await imageRepository.deleteLocalImage(folderName: MissionUtils.folderName, fileName: imageFileName)
                }
                
            case let .published(imageUrl):
                try await missionRepository.deleteMission(mission: mission, imageUrl: imageUrl)
            
            case let .error(imageFileName):
                try await missionRepository.deleteLocalMission(missionId: mission.id)
                if let imageFileName {
                    try await imageRepository.deleteLocalImage(folderName: MissionUtils.folderName, fileName: imageFileName)
                }
        }
    }
}
