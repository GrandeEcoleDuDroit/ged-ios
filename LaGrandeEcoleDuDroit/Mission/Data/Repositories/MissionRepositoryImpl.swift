import Combine
import Foundation

class MissionRepositoryImpl: MissionRepository {
    private let missionLocalDataSource: MissionLocalDataSource
    private let missionRemoteDataSource: MissionRemoteDataSource
    private var cancellables: Set<AnyCancellable> = []
    private var missionsSubject = CurrentValueSubject<[Mission], Never>([])
    private let tag = String(describing: MissionRepositoryImpl.self)
    
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
        do {
            return try await missionLocalDataSource.getMissions()
        } catch {
            e(tag, "Error getting local missions", error)
            throw error
        }
    }
    
    func getRemoteMissions() async throws -> [Mission] {
        do {
            return try await missionRemoteDataSource.getMissions()
        } catch {
            e(tag, "Error getting remote missions", error)
            throw error
        }
    }
    
    func getLocalMission(missionId: String) async throws -> Mission? {
        do {
            return try await missionLocalDataSource.getMission(missionId: missionId)
        } catch {
            e(tag, "Error getting local mission", error)
            throw error
        }
    }
    
    func createMission(mission: Mission, imageData: Data?) async throws {
        do {
            try await missionLocalDataSource.upsertMission(mission: mission)
            try await missionRemoteDataSource.createMission(mission: mission, imageData: imageData)
        } catch {
            e(tag, "Error creating mission \(mission.id)", error)
            throw error
        }
    }
    
    func updateMission(user: User, mission: Mission, imageData: Data?) async throws {
        do {
            try await missionRemoteDataSource.updateMission(user: user, mission: mission, imageData: imageData)
            try await missionLocalDataSource.upsertMission(mission: mission)
        } catch {
            e(tag, "Error updating mission \(mission.id)", error)
            throw error
        }
    }
    
    func updateLocalMission(mission: Mission) async throws {
        do {
            try await missionLocalDataSource.updateMission(mission: mission)
        } catch {
            e(tag, "Error updating local mission \(mission.id)", error)
            throw error
        }
    }
    
    func upsertLocalMission(mission: Mission) async throws {
        do {
            try await missionLocalDataSource.upsertMission(mission: mission)
        } catch {
            e(tag, "Error upserting local mission \(mission.id)", error)
            throw error
        }
    }
    
    func deleteMission(mission: Mission, imageUrl: String?) async throws {
        do {
            try await missionRemoteDataSource.deleteMission(mission: mission)
            try await missionLocalDataSource.deleteMission(missionId: mission.id)
        } catch {
            e(tag, "Error deleting mission \(mission.id)", error)
            throw error
        }
    }
    
    func deleteLocalMissions() async throws {
        do {
            try await missionLocalDataSource.deleteMissions()
        } catch {
            e(tag, "Error deleting local missions", error)
            throw error
        }
    }
    
    func deleteLocalMission(missionId: String) async throws {
        do {
            try await missionLocalDataSource.deleteMission(missionId: missionId)
        } catch {
            e(tag, "Error deleting local mission \(missionId)", error)
            throw error
        }
    }
    
    func addParticipant(missionId: String, user: User) async throws {
        do {
            try await missionRemoteDataSource.addParticipant(missionId: missionId, user: user)
            try await missionLocalDataSource.addParticipant(missionId: missionId, user: user)
        } catch let error as ServerError {
            e(tag, "Error adding participant to mission \(missionId)", error)
            throw switch error.errorCode {
                case MissionError.schoolLevelNotAllowed.code: MissionError.schoolLevelNotAllowed
                case MissionError.maxParticipantsNumberReached.code: MissionError.maxParticipantsNumberReached
                default: error
            }
        } catch {
            e(tag, "Error adding participant to mission \(missionId)", error)
            throw error
        }
    }
    
    func removeParticipant(missionId: String, userId: String) async throws {
        do {
            try await missionRemoteDataSource.removeParticipant(missionId: missionId, userId: userId)
            try await missionLocalDataSource.removeParticipant(missionId: missionId, userId: userId)
        } catch {
            e(tag, "Error removing participant from mission \(missionId)", error)
            throw error
        }
    }
    
    func reportMission(report: MissionReport) async throws {
        do {
            try await missionRemoteDataSource.reportMission(report: report)
        } catch {
            e(tag, "Error reporting mission \(report.missionId)", error)
            throw error
        }
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
