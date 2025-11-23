import Combine
import Foundation

class MissionRepositoryImpl: MissionRepository {
    private let missionLocalDataSource: MissionLocalDataSource
    private let missionRemoteDataSource: MissionRemoteDataSource
    
    private var missionsSubject = CurrentValueSubject<[Mission], Never>([])
    var missions: AnyPublisher<[Mission], Never> {
        missionsSubject.eraseToAnyPublisher()
    }
    var currentMissions: [Mission] {
        missionsSubject.value
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        missionLocalDataSource: MissionLocalDataSource,
        missionRemoteDataSource: MissionRemoteDataSource
    ) {
        self.missionLocalDataSource = missionLocalDataSource
        self.missionRemoteDataSource = missionRemoteDataSource
        loadMissions()
        listenDataChanges()
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
    
    func getRemoteMissions() async throws -> [Mission] {
        try await missionRemoteDataSource.getMissions()
    }
    
    func createMission(mission: Mission, imageFileName: String?, imageData: Data?) async throws {
        try await missionLocalDataSource.upsertMission(mission: mission)
        try await missionRemoteDataSource.createMission(mission: mission, imageFileName: imageFileName, imageData: imageData)
    }
    
    func upsertLocalMission(mission: Mission) async throws {
        try await missionLocalDataSource.upsertMission(mission: mission)
    }
    
    func deleteMission(mission: Mission) async throws {
        try await missionLocalDataSource.deleteMission(missionId: mission.id)
    }
    
    func deleteLocalMission(missionId: String) async throws {
        try await missionLocalDataSource.deleteMission(missionId: missionId)
    }
}
