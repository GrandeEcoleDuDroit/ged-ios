import Combine
import Foundation

class MockMissionRepository: MissionRepository {
    var missions: AnyPublisher<[Mission], Never> { Empty().eraseToAnyPublisher() }
    
    var currentMissions: [Mission] { [] }
    
    func getMissionPublisher(missionId: String) -> AnyPublisher<Mission, Never> { Empty().eraseToAnyPublisher() }
    
    func getLocalMissions() async throws -> [Mission] { [] }

    func getRemoteMissions() async throws -> [Mission] { [] }
    
    func createMission(mission: Mission, imageData: Data?) async throws {}
    
    func updateMission(mission: Mission, imageData: Data?) async throws {}
    
    func updateLocalMission(mission: Mission) async throws {}
    
    func upsertLocalMission(mission: Mission) async throws {}
    
    func deleteMission(mission: Mission, imageUrl: String?) async throws {}
    
    func deleteLocalMission(missionId: String) async throws {}
    
    func addParticipant(addMissionParticipant: AddMissionParticipant) async throws {}
    
    func removeParticipant(missionId: String, userId: String) async throws {}
    
    func reportMission(report: MissionReport) async throws {}
}
