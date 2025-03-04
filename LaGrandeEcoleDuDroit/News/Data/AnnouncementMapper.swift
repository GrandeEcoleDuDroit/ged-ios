import Foundation
import CoreData

class AnnouncementMapper {
    static func toDomain(remoteAnnouncementWithUser: RemoteAnnouncementWithUser) -> Announcement {
        let user = User(
            id: remoteAnnouncementWithUser.userId,
            firstName: remoteAnnouncementWithUser.userFirstName,
            lastName: remoteAnnouncementWithUser.userLastName,
            email: remoteAnnouncementWithUser.userEmail,
            schoolLevel: remoteAnnouncementWithUser.userSchoolLevel,
            isMember: remoteAnnouncementWithUser.userIsMember == 1,
            profilePictureUrl: UserMapper.formatProfilePictureUrl(
                fileName: remoteAnnouncementWithUser.userProfilePictureFileName
            )
        )
        
        return Announcement(
            id: remoteAnnouncementWithUser.announcementId,
            title: remoteAnnouncementWithUser.announcementTitle ?? "",
            content: remoteAnnouncementWithUser.announcementContent,
            date: Date(timeIntervalSince1970: TimeInterval(remoteAnnouncementWithUser.announcementDate)),
            author: user,
            state: .published
        )
    }
    
    static func toDomain(localAnnouncement: LocalAnnouncement) -> Announcement {
        let user = User(
            id: localAnnouncement.userId ?? "",
            firstName: localAnnouncement.userFirstName ?? "",
            lastName: localAnnouncement.userLastName ?? "",
            email: localAnnouncement.userEmail ?? "",
            schoolLevel: localAnnouncement.userSchoolLevel ?? "",
            isMember: localAnnouncement.userIsMember,
            profilePictureUrl: localAnnouncement.userProfilePictureUrl
        )
        
        return Announcement(
            id: localAnnouncement.announcementId ?? "",
            title: localAnnouncement.announcementTitle ?? "",
            content: localAnnouncement.announcementContent ?? "",
            date: Date(timeIntervalSince1970: TimeInterval(localAnnouncement.announcementDate)),
            author: user,
            state: localAnnouncement.announcementState?.description != nil ? AnnouncementState.from(description: localAnnouncement.announcementState!.description)! : .idle
        )
    }
    
    static func toLocal(announcement: Announcement, context: NSManagedObjectContext) {
        let localAnnouncement = LocalAnnouncement(context: context)
        localAnnouncement.announcementId = announcement.id
        localAnnouncement.announcementTitle = announcement.title
        localAnnouncement.announcementContent = announcement.content
        localAnnouncement.announcementDate = Int32(announcement.date.timeIntervalSince1970)
        localAnnouncement.announcementState = announcement.state.description
        localAnnouncement.userId = announcement.author.id
        localAnnouncement.userFirstName = announcement.author.firstName
        localAnnouncement.userLastName = announcement.author.lastName
        localAnnouncement.userEmail = announcement.author.email
        localAnnouncement.userSchoolLevel = announcement.author.schoolLevel
        localAnnouncement.userIsMember = announcement.author.isMember
        localAnnouncement.userProfilePictureUrl = announcement.author.profilePictureUrl
    }
    
    static func toRemoteWithUser(announcement: Announcement) -> RemoteAnnouncementWithUser {
        RemoteAnnouncementWithUser(
            announcementId: announcement.id,
            announcementTitle: announcement.title,
            announcementContent: announcement.content,
            announcementDate: Int(announcement.date.timeIntervalSince1970),
            userId: announcement.author.id,
            userFirstName: announcement.author.firstName,
            userLastName: announcement.author.lastName,
            userEmail: announcement.author.email,
            userSchoolLevel: announcement.author.schoolLevel,
            userIsMember: announcement.author.isMember ? 1 : 0,
            userProfilePictureFileName: UserMapper.getFileNameFromUrl(url: announcement.author.profilePictureUrl)
        )
    }
    
    static func toRemote(announcement: Announcement) -> RemoteAnnouncement {
        RemoteAnnouncement(
            announcementId: announcement.id,
            announcementTitle: announcement.title,
            announcementContent: announcement.content,
            announcementDate: Int(announcement.date.timeIntervalSince1970),
            userId: announcement.author.id
        )
    }
}
