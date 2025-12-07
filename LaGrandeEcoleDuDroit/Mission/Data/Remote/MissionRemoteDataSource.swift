import Foundation

class MissionRemoteDataSource {
    private let missionApi: MissionApi
    private let tag = String(describing: MissionRemoteDataSource.self)
    
    init(missionApi: MissionApi) {
        self.missionApi = missionApi
    }
    
    func getMissions() async throws -> [Mission] {
        try await mapServerError(
            block: { try await missionApi.getMissions() },
            tag: tag,
            message: "Failed to get remote missions"
        ).map { $0.toMission() }
    }
    
    func createMission(mission: Mission, imageData: Data?) async throws {
        try await mapServerError(
            block: {
                try await missionApi.createMission(
                    remoteMission: mission.toRemote()!,
                    imageData: imageData
                )
            },
            tag: tag,
            message: "Failed to create remote missions"
        )
    }
    
    func updateMission(mission: Mission, imageData: Data?) async throws {
        try await mapServerError(
            block: {
                try await missionApi.updateMission(
                    remoteMission: mission.toRemote()!,
                    imageData: imageData
                )
            },
            tag: tag,
            message: "Failed to update remote missions"
        )
    }
    
    func deleteMission(missionId: String, imageFileName: String?) async throws {
        try await mapServerError(
            block: {
                try await missionApi.deleteMission(missionId: missionId, imageFileName: imageFileName)
            },
            tag: tag,
            message: "Failed to delete remote missions"
        )
    }
    
    func addParticipant(addMissionParticipant: AddMissionParticipant) async throws {
        try await mapServerError(
            block: {
                try await missionApi.addParticipant(remoteAddMissionParticipant: addMissionParticipant.toRemote())
            },
            tag: tag,
            message: "Failed to add participant to mission"
        )
    }
    
    func removeParticipant(missionId: String, userId: String) async throws {
        try await mapServerError(
            block: {
                try await missionApi.removeParticipant(missionId: missionId, userId: userId)
            },
            tag: tag,
            message: "Failed to remove participant from mission"
        )
    }
    
    func reportMission(report: MissionReport) async throws {
        try await mapServerError(
            block: {
                try await missionApi.reportMission(report: report.toRemote())
            },
            tag: tag,
            message: "Failed to report mission"
        )
    }
}
