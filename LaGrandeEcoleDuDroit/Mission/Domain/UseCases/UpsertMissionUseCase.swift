class UpsertMissionUseCase {
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
        let localMission = try await missionRepository.getLocalMission(missionId: mission.id)
        try await missionRepository.upsertLocalMission(mission: mission)
        
        if let imagePath = localMission?.state.getImagePath() {
            try await imageRepository.deleteLocalImage(imagePath: imagePath)
        }
    }
}
