class MockFetchMissionsUseCase: FetchMissionsUseCase {
    
    override init(
        missionRepository: MissionRepository = MockMissionRepository(),
        deleteMissionUseCase: DeleteMissionUseCase = MockDeleteMissionUseCase(),
        upsertMissionUseCase: UpsertMissionUseCase = MockUpsertMissionUseCase()
    ) {
        super.init(
            missionRepository: missionRepository,
            deleteMissionUseCase: deleteMissionUseCase,
            upsertMissionUseCase: upsertMissionUseCase
        )
    }
    
    override func execute() async throws {}
}
