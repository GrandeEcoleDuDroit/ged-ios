import Foundation

protocol MissionApi {
    func getMissions() async throws -> [InboundRemoteMission]
    
    func createMission(remoteMission: OutboundRemoteMission, fileData: FileData?) async throws
    
    func updateMission(userId: String, remoteMission: OutboundRemoteMission, fileData: FileData?) async throws
    
    func deleteMission(remoteMission: OutboundRemoteMission) async throws
    
    func addParticipant(missionId: String, oracleUser: OracleUser) async throws
    
    func removeParticipant(missionId: String, userId: String) async throws
    
    func reportMission(report: RemoteMissionReport) async throws
}
