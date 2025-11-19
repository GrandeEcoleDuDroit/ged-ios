class MockSynchronizeMissionsUseCase: SynchronizeMissionsUseCase {
    
    override init(missionRepository: MissionRepository = MockMissionRepository()) {
        super.init(missionRepository: missionRepository)
    }
    
    override func execute() async throws {}
}
