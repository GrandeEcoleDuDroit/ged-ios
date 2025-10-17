import CoreData

actor AnnouncementCoreDataActor {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAnnouncements() async throws -> [Announcement] {
        try await context.perform {
            let fetchRequest = LocalAnnouncement.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(
                key: AnnouncementField.Local.announcementDate,
                ascending: false
            )]
            
            let announcements =  try self.context.fetch(fetchRequest)
            return announcements.compactMap { $0.toAnnouncement() }
        }
    }
  
    func upsert(announcement: Announcement) async throws {
        try await context.perform {
            let request = LocalAnnouncement.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                AnnouncementField.Local.announcementId, announcement.id
            )
            
            let localAnnouncement = try self.context.fetch(request).first
            guard localAnnouncement?.equals(announcement) != true else {
                return
            }
            
            if localAnnouncement != nil {
                localAnnouncement?.modify(announcement: announcement)
            } else {
                let newLocalAnnouncement = LocalAnnouncement(context: self.context)
                newLocalAnnouncement.modify(announcement: announcement)
            }
            
            try self.context.save()
        }
    }
    
    func update(announcement: Announcement) async throws {
        try await context.perform {
            let request = LocalAnnouncement.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                AnnouncementField.Local.announcementId, announcement.id
            )
            
            try self.context
                .fetch(request)
                .first?
                .modify(announcement: announcement)
            
            try self.context.save()
        }
    }
    
    func delete(announcementId: String) async throws {
        try await context.perform {
            let request = LocalAnnouncement.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                AnnouncementField.Local.announcementId, announcementId
            )
            
            try self.context.fetch(request).first.map {
                self.context.delete($0)
            }
            
            try self.context.save()
        }
    }
    
    func deleteAll() async throws {
        try await context.perform {
            let request = LocalAnnouncement.fetchRequest()
            let announcements = try self.context.fetch(request)
            announcements.forEach { self.context.delete($0) }
            
            try self.context.save()
        }
    }
    
    func deleteAll(userId: String) async throws {
        try await context.perform {
            let request = LocalAnnouncement.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                AnnouncementField.Local.userId, userId
            )
            
            let announcements = try self.context.fetch(request)
            announcements.forEach { self.context.delete($0) }
            
            try self.context.save()
        }
    }
}
