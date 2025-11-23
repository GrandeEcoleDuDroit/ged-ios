import Combine
import Foundation

class MockMissionRepository: MissionRepository {
    var missions: AnyPublisher<[Mission], Never> {
        Empty<[Mission], Never>().eraseToAnyPublisher()
    }
    
    var currentMissions: [Mission] { [] }
    
    func getRemoteMissions() async throws -> [Mission] { [] }
    
    func createMission(mission: Mission, imageFileName: String?, imageData: Data?) async throws {}
    
    func upsertLocalMission(mission: Mission) async throws {}
    
    func deleteMission(mission: Mission) async throws {}
    
    func deleteLocalMission(missionId: String) async throws {}
}
