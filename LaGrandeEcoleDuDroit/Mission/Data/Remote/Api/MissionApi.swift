import Foundation

protocol MissionApi {
    func getMissions() async throws -> (URLResponse, [InboundRemoteMission])
    
    func createMission(
        remoteMission: OutboundRemoteMission,
        imageFileName: String?,
        imageData: Data?
    ) async throws -> (URLResponse, ServerResponse)
}
