class MissionRemoteDataSource {
    private let missionApi: MissionApi
    private let tag = String(describing: MissionRemoteDataSource.self)
    
    init(missionApi: MissionApi) {
        self.missionApi = missionApi
    }
    
    func getMissions() async throws -> [Mission] {
        try await mapServerError(
            block: { try await missionApi.getMissions() },
            tag: tag,
            message: "Failed to get remote missions"
        ).map { $0.toMission() }
    }
}
