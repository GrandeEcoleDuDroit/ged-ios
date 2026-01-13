import Foundation

protocol MissionApi {
    func getMissions() async throws -> [InboundRemoteMission]
    
    func createMission(remoteMission: OutboundRemoteMission, imageData: Data?) async throws
    
    func updateMission(remoteMission: OutboundRemoteMission, imageData: Data?) async throws
    
    func deleteMission(remoteMission: OutboundRemoteMission) async throws
    
    func addParticipant(missionId: String, oracleUser: OracleUser) async throws
    
    func removeParticipant(missionId: String, userId: String) async throws
    
    func reportMission(report: RemoteMissionReport) async throws
}
