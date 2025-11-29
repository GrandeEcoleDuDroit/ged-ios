import Foundation

protocol MissionApi {
    func getMissions() async throws -> (URLResponse, [InboundRemoteMission])
    
    func createMission(remoteMission: OutboundRemoteMission, imageData: Data?) async throws -> (URLResponse, ServerResponse)
    
    func deleteMission(missionId: String, imageFileName: String?) async throws -> (URLResponse, ServerResponse)
}
