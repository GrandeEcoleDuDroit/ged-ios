class FetchMissionsUseCase {
    private let missionRepository: MissionRepository
    private let deleteMissionUseCase: DeleteMissionUseCase
    private let upsertMissionUseCase: UpsertMissionUseCase
    
    init(
        missionRepository: MissionRepository,
        deleteMissionUseCase: DeleteMissionUseCase,
        upsertMissionUseCase: UpsertMissionUseCase
    ) {
        self.missionRepository = missionRepository
        self.deleteMissionUseCase = deleteMissionUseCase
        self.upsertMissionUseCase = upsertMissionUseCase
    }
    
    func execute() async throws {
        let missions = missionRepository.currentMissions
        let remoteMissions = try await missionRepository.getRemoteMissions()
        
        let missionsToDelete = missions.filter { $0.state.type == .publishedType && !remoteMissions.contains($0) }
        let missionsToUpsert = remoteMissions.filter { !missions.contains($0) }
        
        for mission in missionsToDelete {
            try? await deleteMissionUseCase.execute(mission: mission)
        }
        for mission in missionsToUpsert {
            try? await upsertMissionUseCase.execute(mission: mission)
        }
    }
}
