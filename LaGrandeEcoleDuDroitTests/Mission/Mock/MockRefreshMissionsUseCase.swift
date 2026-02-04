class MockFetchMissionsUseCase: FetchMissionsUseCase {
    
    override init(
        missionRepository: MissionRepository = MockMissionRepository(),
        upsertMissionUseCase: UpsertMissionUseCase = MockUpsertMissionUseCase()
    ) {
        super.init(
            missionRepository: missionRepository,
            upsertMissionUseCase: upsertMissionUseCase
        )
    }
    
    override func execute() async throws {}
}
