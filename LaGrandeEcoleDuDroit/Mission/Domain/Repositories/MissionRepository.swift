import Combine
import Foundation

protocol MissionRepository {
    var missions: AnyPublisher<[Mission], Never> { get }

    var currentMissions: [Mission] { get }
        
    func getRemoteMissions() async throws -> [Mission]
    
    func createMission(mission: Mission, imageFileName: String?, imageData: Data?) async throws
    
    func upsertLocalMission(mission: Mission) async throws
    
    func deleteMission(mission: Mission) async throws
    
    func deleteLocalMission(missionId: String) async throws
}
