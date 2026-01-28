class MockUpsertMissionUseCase: UpsertMissionUseCase {
    override init(
        missionRepository: MissionRepository = MockMissionRepository(),
        imageRepository: ImageRepository = MockImageRepository()
    ) {
        super.init(
            missionRepository: missionRepository,
            imageRepository: imageRepository
        )
    }
    
    override func execute(mission: Mission) async throws {}
}
