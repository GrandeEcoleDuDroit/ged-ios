import Combine
import CoreData

class MissionLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private let missionActor: MissionCoreDataActor
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
        missionActor = MissionCoreDataActor(context: context)
    }
    
    func listenDataChanges() -> AnyPublisher<CoreDataChange<Mission>, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .collect(.byTime(RunLoop.current, .milliseconds(100)))
            .map { notifications in
                
                let extractIDs: (String) -> [NSManagedObjectID] = { key in
                    notifications.flatMap {
                        ($0.userInfo?[key] as? Set<NSManagedObject>)?
                            .compactMap { $0 as? LocalMission }
                            .map(\.objectID) ?? []
                    }
                }

                let inserted = extractIDs(NSInsertedObjectsKey)
                let updated = extractIDs(NSUpdatedObjectsKey)
              
                return (inserted: inserted, updated: updated)
            }
            .flatMap { objectIds in
                Future<CoreDataChange<Mission>, Never> { promise in
                    Task { [weak self] in
                        let inserted = await self?.missionActor
                            .resolve(objectIds.inserted)
                            .compactMap { localMission in
                                localMission.toMission(getImagePath: { self?.getImagePath($0) })
                            } ?? []
                        
                        let updated = await self?.missionActor
                            .resolve(objectIds.updated)
                            .compactMap { localMission in
                                localMission.toMission(getImagePath: { self?.getImagePath($0) })
                            } ?? []
                        
                        promise(.success(CoreDataChange(inserted: inserted, updated: updated)))
                    }
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getMissions() async throws -> [Mission] {
        try await missionActor.getMissions().compactMap { $0.toMission(getImagePath: getImagePath) }
    }
    
    func upsertMission(mission: Mission) async throws {
        try await missionActor.upsert(mission: mission)
    }
    
    func deleteMission(missionId: String) async throws {
        try await missionActor.delete(missionId: missionId)
    }
    
    func addParticipant(missionId: String, user: User) async throws {
        let localMisison = try await missionActor.getMission(missionId: missionId)
        var mission = localMisison.toMission(getImagePath: getImagePath)!
        mission.participants = mission.participants + [user]
        try await missionActor.upsert(mission: mission)
    }
    
    func removeParticipant(missionId: String, userId: String) async throws {
        let localMisison = try await missionActor.getMission(missionId: missionId)
        var mission = localMisison.toMission(getImagePath: getImagePath)!
        mission.participants = mission.participants.filter { $0.id != userId }
        try await missionActor.upsert(mission: mission)
    }
    
    private func getImagePath(_ fileName: String) -> String? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        .first?
        .appending(path: MissionUtils.ImageFile.relativePath(fileName: fileName), directoryHint: .inferFromPath)
        .path()
    }
}
