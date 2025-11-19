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
                        let inserted = await self?.missionActor.resolve(objectIds.inserted) ?? []
                        let updated = await self?.missionActor.resolve(objectIds.updated) ?? []
                        
                        promise(.success(CoreDataChange(inserted: inserted, updated: updated)))
                    }
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getMissions() async throws -> [Mission] {
        try await missionActor.getMissions()
    }
    
    func upsertMission(mission: Mission) async throws {
        try await missionActor.upsert(mission: mission)
    }
    
    func deleteMission(missionId: String) async throws {
        try await missionActor.delete(missionId: missionId)
    }
}
