class FetchMissionsUseCase {
    private let missionRepository: MissionRepository
    private let upsertMissionUseCase: UpsertMissionUseCase
    
    init(
        missionRepository: MissionRepository,
        upsertMissionUseCase: UpsertMissionUseCase
    ) {
        self.missionRepository = missionRepository
        self.upsertMissionUseCase = upsertMissionUseCase
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
            try? await upsertMissionUseCase.execute(mission: mission)
        }
    }
}
