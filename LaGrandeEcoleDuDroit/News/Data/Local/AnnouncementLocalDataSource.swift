import Foundation
import Combine
import CoreData
import os

class AnnouncementLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private let announcementActor :AnnouncementCoreDataActor
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
        announcementActor = AnnouncementCoreDataActor(context: context)
    }
    
    func listenDataChange() -> AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .eraseToAnyPublisher()
    }
    
    func getAnnouncements() async throws -> [Announcement] {
        try await context.perform {
            let fetchRequest = LocalAnnouncement.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(
                key: AnnouncementField.announcementDate,
                ascending: false
            )]
            
            let announcements =  try self.context.fetch(fetchRequest)
            return announcements.compactMap { $0.toAnnouncement() }
        }
    }
    
    func upsertAnnouncement(announcement: Announcement) async throws {
        try await announcementActor.upsert(announcement: announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await announcementActor.update(announcement: announcement)
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await announcementActor.delete(announcementId: announcementId)
    }
}
    
private actor AnnouncementCoreDataActor {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
  
    func upsert(announcement: Announcement) async throws {
        try await context.perform {
            let request = LocalAnnouncement.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                AnnouncementField.announcementId, announcement.id
            )
            
            let localAnnouncement = try self.context.fetch(request).first
            guard localAnnouncement?.equals(announcement) != true else {
                return
            }
            
            if localAnnouncement != nil {
                localAnnouncement?.modify(announcement: announcement)
            } else {
                let newLocalAnnouncement = LocalAnnouncement(context: self.context)
                announcement.buildLocal(localAnnouncement: newLocalAnnouncement)
            }
            
            try self.context.save()
        }
    }
    
    func update(announcement: Announcement) async throws {
        try await context.perform {
            let request = LocalAnnouncement.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                AnnouncementField.announcementId, announcement.id
            )
            
            try self.context.fetch(request).first?.modify(announcement: announcement)
            
            try self.context.save()
        }
    }
    
    func delete(announcementId: String) async throws {
        try await context.perform {
            let request = LocalAnnouncement.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                AnnouncementField.announcementId, announcementId
            )
            
            try self.context.fetch(request).first.map {
                self.context.delete($0)
            }
            
            try self.context.save()
        }
    }
}

private extension Announcement {
    func buildLocal(localAnnouncement: LocalAnnouncement) {
        localAnnouncement.announcementId = id
        localAnnouncement.announcementTitle = title
        localAnnouncement.announcementContent = content
        localAnnouncement.announcementDate = date
        localAnnouncement.announcementState = state.rawValue
        localAnnouncement.userId = author.id
        localAnnouncement.userFirstName = author.firstName
        localAnnouncement.userLastName = author.lastName
        localAnnouncement.userEmail = author.email
        localAnnouncement.userSchoolLevel = author.schoolLevel.rawValue
        localAnnouncement.userIsMember = author.isMember
        localAnnouncement.userProfilePictureFileName = UrlUtils.getFileNameFromUrl(url: author.profilePictureUrl)
    }
}

private extension LocalAnnouncement {
    func modify(announcement: Announcement) {
        announcementTitle = announcement.title
        announcementContent = announcement.content
        announcementDate = announcement.date
        announcementState = announcement.state.rawValue
        userId = announcement.author.id
        userFirstName = announcement.author.firstName
        userLastName = announcement.author.lastName
        userEmail = announcement.author.email
        userSchoolLevel = announcement.author.schoolLevel.rawValue
        userIsMember = announcement.author.isMember
        userProfilePictureFileName = announcement.author.profilePictureUrl
    }
    
    func equals(_ announcement: Announcement) -> Bool {
        announcementId == announcement.id &&
        announcementTitle == announcement.title &&
        announcementContent == announcement.content &&
        announcementDate == announcement.date &&
        announcementState == announcement.state.rawValue &&
        userId == announcement.author.id &&
        userFirstName == announcement.author.firstName &&
        userLastName == announcement.author.lastName &&
        userEmail == announcement.author.email &&
        userSchoolLevel == announcement.author.schoolLevel.rawValue &&
        userIsMember == announcement.author.isMember &&
        userProfilePictureFileName == UrlUtils.getFileNameFromUrl(url: announcement.author.profilePictureUrl)
    }
}
