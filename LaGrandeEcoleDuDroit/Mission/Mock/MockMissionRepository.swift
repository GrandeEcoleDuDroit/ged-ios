import Combine
import Foundation

class MockMissionRepository: MissionRepository {
    var missions: AnyPublisher<[Mission], Never> {
        Empty<[Mission], Never>().eraseToAnyPublisher()
    }
    
    var currentMissions: [Mission] { [] }
    
    func getRemoteMissions() async throws -> [Mission] { [] }
    
    func createMission(mission: Mission, imageData: Data?) async throws {}
    
    func upsertLocalMission(mission: Mission) async throws {}
    
    func deleteMission(mission: Mission, imageUrl: String?) async throws {}
    
    func deleteLocalMission(missionId: String) async throws {}
}
