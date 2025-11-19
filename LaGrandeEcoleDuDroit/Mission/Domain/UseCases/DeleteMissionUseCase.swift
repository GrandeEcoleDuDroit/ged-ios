class DeleteMissionUseCase {
    private let missionRepository: MissionRepository
    
    init(missionRepository: MissionRepository) {
        self.missionRepository = missionRepository
    }
    
    func execute(mission: Mission) async throws {
        switch mission.state {
            case .draft: try await missionRepository.deleteLocalMission(missionId: mission.id)
                
            case .publishing: try await missionRepository.deleteLocalMission(missionId: mission.id)
                
            case .published: try await missionRepository.deleteMission(mission: mission)
            
            case .error: try await missionRepository.deleteLocalMission(missionId: mission.id)
        }
    }
}
