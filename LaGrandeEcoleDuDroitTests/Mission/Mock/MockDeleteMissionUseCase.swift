class MockDeleteMissionUseCase: DeleteMissionUseCase {
    override init(
        missionRepository: MissionRepository = MockMissionRepository(),
        imageRepository: ImageRepository = MockImageRepository(),
        missionTaskQueue: MissionTaskQueue = MissionTaskQueue()
    ) {
        super.init(
            missionRepository: missionRepository,
            imageRepository: imageRepository,
            missionTaskQueue: missionTaskQueue
        )
    }
}
