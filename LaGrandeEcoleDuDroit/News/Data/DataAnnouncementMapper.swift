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
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: userProfilePictureFileName),
            isDeleted: userIsDeleted == 1
        )
        
        return Announcement(
            id: announcementId,
            title: announcementTitle ?? "",
            content: announcementContent,
            date: announcementDate.toDate(),
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
            announcementDate: date.toEpochMilli(),
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
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: userProfilePictureFileName),
            isDeleted: isDeleted
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
    
    func modify(announcement: Announcement) {
        announcementId = announcement.id
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
        userProfilePictureFileName = UrlUtils.extractFileName(url: announcement.author.profilePictureUrl)
        userIsDeleted = announcement.author.isDeleted
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
        userProfilePictureFileName == UrlUtils.extractFileName(url: announcement.author.profilePictureUrl) &&
        userIsDeleted == announcement.author.isDeleted
    }
}

extension AnnouncementReport {
    func toRemote() -> RemoteAnnouncementReport {
        RemoteAnnouncementReport(
            announcementId: announcementId,
            authorInfo: authorInfo.toRemote(),
            userInfo: userInfo.toRemote(),
            reason: reason.rawValue
        )
    }
}

extension AnnouncementReport.UserInfo {
    func toRemote() -> RemoteAnnouncementReport.RemoteUserInfo {
        RemoteAnnouncementReport.RemoteUserInfo(
            fullName: fullName,
            email: email
        )
    }
}
