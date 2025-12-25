import Combine
import Foundation

class MissionRepositoryImpl: MissionRepository {
    private let missionLocalDataSource: MissionLocalDataSource
    private let missionRemoteDataSource: MissionRemoteDataSource
    private var cancellables: Set<AnyCancellable> = []
    private var missionsSubject = CurrentValueSubject<[Mission], Never>([])
    
    var missions: AnyPublisher<[Mission], Never> {
        missionsSubject.eraseToAnyPublisher()
    }
    var currentMissions: [Mission] {
        missionsSubject.value
    }
    
    init(
        missionLocalDataSource: MissionLocalDataSource,
        missionRemoteDataSource: MissionRemoteDataSource
    ) {
        self.missionLocalDataSource = missionLocalDataSource
        self.missionRemoteDataSource = missionRemoteDataSource
        loadMissions()
        listenDataChanges()
    }
    
    func getMissionPublisher(missionId: String) -> AnyPublisher<Mission, Never> {
        missionsSubject.compactMap { missions in
            missions.first {
                $0.id == missionId
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getLocalMissions() async throws -> [Mission] {
        try await missionLocalDataSource.getMissions()
    }
    
    func getRemoteMissions() async throws -> [Mission] {
        try await missionRemoteDataSource.getMissions()
    }
    
    func createMission(mission: Mission, imageData: Data?) async throws {
        try await missionLocalDataSource.upsertMission(mission: mission)
        try await missionRemoteDataSource.createMission(mission: mission, imageData: imageData)
    }
    
    func updateMission(mission: Mission, imageData: Data?) async throws {
        try await missionRemoteDataSource.updateMission(mission: mission, imageData: imageData)
        try await missionLocalDataSource.upsertMission(mission: mission)
    }
    
    func updateLocalMission(mission: Mission) async throws {
        try await missionLocalDataSource.updateMission(mission: mission)
    }
    
    func upsertLocalMission(mission: Mission) async throws {
        try await missionLocalDataSource.upsertMission(mission: mission)
    }
    
    func deleteMission(mission: Mission, imageUrl: String?) async throws {
        try await missionRemoteDataSource.deleteMission(mission: mission)
        try await missionLocalDataSource.deleteMission(missionId: mission.id)
    }
    
    func deleteLocalMission(missionId: String) async throws {
        try await missionLocalDataSource.deleteMission(missionId: missionId)
    }
    
    func addParticipant(addMissionParticipant: AddMissionParticipant) async throws {
        try await missionRemoteDataSource.addParticipant(addMissionParticipant: addMissionParticipant)
        try await missionLocalDataSource.addParticipant(missionId: addMissionParticipant.missionId, user: addMissionParticipant.user)
    }
    
    func removeParticipant(missionId: String, userId: String) async throws {
        try await missionRemoteDataSource.removeParticipant(missionId: missionId, userId: userId)
        try await missionLocalDataSource.removeParticipant(missionId: missionId, userId: userId)
    }
    
    func reportMission(report: MissionReport) async throws {
        try await missionRemoteDataSource.reportMission(report: report)
    }
    
    private func listenDataChanges() {
        missionLocalDataSource.listenDataChanges()
            .sink { [weak self] _ in
                self?.loadMissions()
            }.store(in: &cancellables)
    }
    
    private func loadMissions() {
        Task {
            if let missions = try? await missionLocalDataSource.getMissions() {
                missionsSubject.send(missions)
            }
        }
    }
}
