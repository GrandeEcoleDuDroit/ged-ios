import Combine

protocol MissionRepository {
    var missions: AnyPublisher<[Mission], Never> { get }

    var currentMissions: [Mission] { get }
        
    func getRemoteMissions() async throws -> [Mission]
    
    func upsertLocalMission(mission: Mission) async throws
    
    func deleteMission(mission: Mission) async throws
    
    func deleteLocalMission(missionId: String) async throws
}
