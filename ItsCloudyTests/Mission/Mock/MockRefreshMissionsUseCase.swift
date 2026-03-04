class MockFetchMissionsUseCase: FetchMissionsUseCase {
    
    override init(
        missionRepository: MissionRepository = MockMissionRepository(),
        upsertLocalMissionUseCase: UpsertLocalMissionUseCase = MockUpsertLocalMissionUseCase()
    ) {
        super.init(
            missionRepository: missionRepository,
            upsertLocalMissionUseCase: upsertLocalMissionUseCase
        )
    }
    
    override func execute() async throws {}
}
