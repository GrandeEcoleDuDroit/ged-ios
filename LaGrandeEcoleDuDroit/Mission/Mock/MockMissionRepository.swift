import Combine

class MockMissionRepository: MissionRepository {
    var missions: AnyPublisher<[Mission], Never> {
        Empty<[Mission], Never>().eraseToAnyPublisher()
    }
    
    var currentMissions: [Mission] { [] }
    
    func getRemoteMissions() async throws -> [Mission] { [] }
    
    func upsertLocalMission(mission: Mission) async throws {}
    
    func deleteMission(mission: Mission) async throws {}
    
    func deleteLocalMission(missionId: String) async throws {}
}
