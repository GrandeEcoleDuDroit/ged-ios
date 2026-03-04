class FetchMissionsUseCase {
    private let missionRepository: MissionRepository
    private let upsertLocalMissionUseCase: UpsertLocalMissionUseCase
    
    init(
        missionRepository: MissionRepository,
        upsertLocalMissionUseCase: UpsertLocalMissionUseCase
    ) {
        self.missionRepository = missionRepository
        self.upsertLocalMissionUseCase = upsertLocalMissionUseCase
    }
    
    func execute() async throws {
        let missions = missionRepository.currentMissions
        let remoteMissions = try await missionRepository.getRemoteMissions()
        
        let missionsToDelete = missions.filter { $0.state.type == .publishedType && !remoteMissions.contains($0) }
        let missionsToUpsert = remoteMissions.filter { !missions.contains($0) }
        
        for mission in missionsToDelete {
            try? await missionRepository.deleteLocalMission(missionId: mission.id)
        }
        for mission in missionsToUpsert {
            try? await upsertLocalMissionUseCase.execute(mission: mission)
        }
    }
}
