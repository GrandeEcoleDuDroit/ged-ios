class MockSynchronizeMissionsUseCase: FetchMissionsUseCase {
    
    override init(missionRepository: MissionRepository = MockMissionRepository()) {
        super.init(missionRepository: missionRepository)
    }
    
    override func execute() async throws {}
}
