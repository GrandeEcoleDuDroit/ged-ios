import Foundation

class MissionRemoteDataSource {
    private let missionApi: MissionApi
    
    init(missionApi: MissionApi) {
        self.missionApi = missionApi
    }
    
    func getMissions() async throws -> [Mission] {
        try await missionApi.getMissions().map { $0.toMission() }
    }
    
    func createMission(mission: Mission, imageData: Data?) async throws {
        try await missionApi.createMission(
            remoteMission: mission.toRemote()!,
            imageData: imageData
        )
    }
    
    func updateMission(mission: Mission, imageData: Data?) async throws {
        try await missionApi.updateMission(
            remoteMission: mission.toRemote()!,
            imageData: imageData
        )
    }
    
    func deleteMission(mission: Mission) async throws {
        try await missionApi.deleteMission(remoteMission: mission.toRemote()!)
    }
    
    func addParticipant(missionId: String, user: User) async throws {
        try await missionApi.addParticipant(missionId: missionId, oracleUser: user.toOracleUser())
    }
    
    func removeParticipant(missionId: String, userId: String) async throws {
        try await missionApi.removeParticipant(missionId: missionId, userId: userId)
    }
    
    func reportMission(report: MissionReport) async throws {
        try await missionApi.reportMission(report: report.toRemote())
    }
}
