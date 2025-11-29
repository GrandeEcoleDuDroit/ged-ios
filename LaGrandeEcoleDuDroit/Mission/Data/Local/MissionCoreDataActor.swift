import CoreData

actor MissionCoreDataActor {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getMissions() async throws -> [LocalMission] {
        try await context.perform {
            let fetchRequest = LocalMission.fetchRequest()
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(
                key: MissionField.Local.missionDate,
                ascending: false
            )]
            
            return try self.context.fetch(fetchRequest)
        }
    }
    
    func resolve(_ ids: [NSManagedObjectID]) -> [LocalMission] {
        self.context.performAndWait {
            ids.compactMap {
                guard let object = try? self.context.existingObject(with: $0) else {
                    return nil
                }
                return (object as? LocalMission)
            }
        }
    }
    
    func upsert(mission: Mission) async throws {
        try await context.perform {
            let request = LocalMission.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                MissionField.Local.missionId, mission.id
            )
            
            let localMission = try self.context.fetch(request).first
            guard localMission?.equals(mission) != true else {
                return
            }
            
            if localMission != nil {
                localMission?.modify(mission: mission)
            } else {
                let newLocalMission = LocalMission(context: self.context)
                newLocalMission.modify(mission: mission)
            }
            
            try self.context.save()
        }
    }
    
    func delete(missionId: String) async throws {
        try await context.perform {
            let request = LocalMission.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                MissionField.Local.missionId, missionId
            )
            
            try self.context.fetch(request).first.map {
                self.context.delete($0)
            }
            
            try self.context.save()
        }
    }
}
