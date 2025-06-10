import Foundation
import CoreData

extension RemoteAnnouncementWithUser {
    func toAnnouncement() -> Announcement {
        let user = User(
            id: userId,
            firstName: userFirstName,
            lastName: userLastName,
            email: userEmail,
            schoolLevel: SchoolLevel.init(rawValue: userSchoolLevel) ?? SchoolLevel.ged1,
            isMember: userIsMember == 1,
            profilePictureUrl: UrlUtils.formatProfilePictureUrl(
                fileName: userProfilePictureFileName
            )
        )
        
        return Announcement(
            id: announcementId,
            title: announcementTitle ?? "",
            content: announcementContent,
            date: Date(timeIntervalSince1970: TimeInterval(announcementDate) / 1000),
            author: user,
            state: .published
        )
    }
}

extension Announcement {    
    func toRemote() -> RemoteAnnouncement {
        RemoteAnnouncement(
            announcementId: id,
            announcementTitle: title,
            announcementContent: content,
            announcementDate: Int64(date.timeIntervalSince1970 * 1000),
            userId: author.id
        )
    }
}

extension LocalAnnouncement {
    func toAnnouncement() -> Announcement? {
        guard let userId = userId,
              let userFirstName = userFirstName,
              let userLastName = userLastName,
              let userEmail = userEmail,
              let userSchoolLevel = userSchoolLevel,
              let announcementId = announcementId,
              let announcementTitle = announcementTitle,
              let announcementContent = announcementContent,
              let announcementDate = announcementDate,
              let announcementState = AnnouncementState(rawValue: announcementState ?? "")
        else { return nil }
        
        let user = User(
            id: userId,
            firstName: userFirstName,
            lastName: userLastName,
            email: userEmail,
            schoolLevel: SchoolLevel.init(rawValue: userSchoolLevel) ?? SchoolLevel.ged1,
            isMember: userIsMember,
            profilePictureUrl: UrlUtils.formatProfilePictureUrl(fileName: userProfilePictureFileName)
        )
        
        return Announcement(
            id: announcementId,
            title: announcementTitle,
            content: announcementContent,
            date: announcementDate,
            author: user,
            state: announcementState
        )
    }
}
