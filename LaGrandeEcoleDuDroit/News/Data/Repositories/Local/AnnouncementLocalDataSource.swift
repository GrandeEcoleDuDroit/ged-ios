import Foundation
import Combine
import CoreData
import os

class AnnouncementLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
    }
    
    func listenDataChange() -> AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.current)
            .eraseToAnyPublisher()
    }
    
    func getAnnouncements() throws -> [Announcement] {
        let fetchRequest = LocalAnnouncement.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(
            key: AnnouncementField.announcementDate,
            ascending: false
        )]
        
        return try context.fetch(fetchRequest).compactMap { $0.toAnnouncement() }
    }
    
    func insertAnnouncement(announcement: Announcement) throws {
        try insert(announcement: announcement)
    }
    
    func upsertAnnouncement(announcement: Announcement) throws {
        let request = LocalAnnouncement.fetchRequest()
        request.predicate = NSPredicate(
            format: "\(AnnouncementField.announcementId) == %@",
            announcement.id
        )
        
        if let localAnnouncement = try? context.fetch(request).first {
            try update(localAnnouncement: localAnnouncement, announcement: announcement)
        } else {
            try insert(announcement: announcement)
        }
    }
    
    func updateAnnouncement(announcement: Announcement) throws {
        try update(announcement: announcement)
    }
    
    func deleteAnnouncement(announcementId: String) throws {
        let request = LocalAnnouncement.fetchRequest()
        request.predicate = NSPredicate(
            format: "\(AnnouncementField.announcementId) == %@",
            announcementId
        )
        
        try context.fetch(request).first.map {
            context.delete($0)
            try context.save()
        }
    }
    
    private func insert(announcement: Announcement) throws {
        announcement.buildLocal(context: context)
        try context.save()
    }
    
    private func update(announcement: Announcement) throws {
        let request = LocalAnnouncement.fetchRequest()
        request.predicate = NSPredicate(
            format: "\(AnnouncementField.announcementId) == %@",
            announcement.id
        )
        try context.fetch(request).first?.modify(announcement: announcement)
        try context.save()
    }
    
    private func update(localAnnouncement: LocalAnnouncement, announcement: Announcement) throws {
        localAnnouncement.modify(announcement: announcement)
        try context.save()
    }
}

private extension Announcement {
    func buildLocal(context: NSManagedObjectContext) {
        let localAnnouncement = LocalAnnouncement(context: context)
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
        localAnnouncement.userProfilePictureFileName = UrlUtils.getFileNameFromUrl(url: author.profilePictureFileName)
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
        userProfilePictureFileName = announcement.author.profilePictureFileName
    }
}
