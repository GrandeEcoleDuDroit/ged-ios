import Foundation

protocol MissionApi {
    func getMissions() async throws -> (URLResponse, [InboundRemoteMission])
}
