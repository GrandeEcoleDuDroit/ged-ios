import Foundation

class AnnouncementMapper {
    static func toAnnouncement(remoteAnnouncement: RemoteAnnouncement) -> Announcement {
        let user = User(
            id: remoteAnnouncement.userId,
            firstName: remoteAnnouncement.userFirstName,
            lastName: remoteAnnouncement.userLastName,
            email: remoteAnnouncement.userEmail,
            schoolLevel: remoteAnnouncement.userSchoolLevel,
            isMember: remoteAnnouncement.userIsMember == 1,
            profilePictureUrl: remoteAnnouncement.userProfilePictureUrl
        )
        
        return Announcement(
            id: remoteAnnouncement.announcementId,
            title: remoteAnnouncement.announcementTitle,
            content: remoteAnnouncement.announcementContent,
            date: Date(timeIntervalSince1970: TimeInterval(remoteAnnouncement.announcementDate)),
            author: user
        )
    }
}
