import Combine
import Foundation

protocol MissionRepository {
    var missions: AnyPublisher<[Mission], Never> { get }

    var currentMissions: [Mission] { get }
    
    func getMissionPublisher(missionId: String) -> AnyPublisher<Mission, Never>
        
    func getLocalMissions() async throws -> [Mission]
    
    func getRemoteMissions() async throws -> [Mission]
    
    func createMission(mission: Mission, imageData: Data?) async throws
    
    func updateMission(user: User, mission: Mission, imageData: Data?) async throws
    
    func updateLocalMission(mission: Mission) async throws
    
    func upsertLocalMission(mission: Mission) async throws
    
    func deleteMission(mission: Mission, imageUrl: String?) async throws
    
    func deleteLocalMissions() async throws
    
    func deleteLocalMission(missionId: String) async throws
    
    func addParticipant(missionId: String, user: User) async throws
    
    func removeParticipant(missionId: String, userId: String) async throws
    
    func reportMission(report: MissionReport) async throws
}
