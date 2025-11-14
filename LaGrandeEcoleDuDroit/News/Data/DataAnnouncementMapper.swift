import Foundation
import CoreData

extension InboundRemoteAnnouncement {
    func toAnnouncement() -> Announcement {
        let user = User(
            id: userId,
            firstName: userFirstName,
            lastName: userLastName,
            email: userEmail,
            schoolLevel: SchoolLevel.init(rawValue: userSchoolLevel) ?? SchoolLevel.ged1,
            admin: userAdmin == 1,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: userProfilePictureFileName),
            state: User.UserState(rawValue: userState) ?? .active,
            tester: userTester == 1
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
    func toRemote() -> OutbondRemoteAnnouncement {
        OutbondRemoteAnnouncement(
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
        guard let authorId = announcementAuthorId,
              let authorFirstName = announcementAuthorFirstName,
              let authorLastName = announcementAuthorLastName,
              let authorEmail = announcementAuthorEmail,
              let authorSchoolLevel = announcementAuthorSchoolLevel,
              let announcementId = announcementId,
              let announcementContent = announcementContent,
              let announcementDate = announcementDate,
              let announcementState = AnnouncementState(rawValue: announcementState ?? "")
        else { return nil }
        
        let user = User(
            id: authorId,
            firstName: authorFirstName,
            lastName: authorLastName,
            email: authorEmail,
            schoolLevel: SchoolLevel(rawValue: authorSchoolLevel) ?? SchoolLevel.unknown,
            admin: announcementAuthorAdmin,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: announcementAuthorProfilePictureFileName),
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
        announcementAuthorId = announcement.author.id
        announcementAuthorFirstName = announcement.author.firstName
        announcementAuthorLastName = announcement.author.lastName
        announcementAuthorEmail = announcement.author.email
        announcementAuthorSchoolLevel = announcement.author.schoolLevel.rawValue
        announcementAuthorAdmin = announcement.author.admin
        announcementAuthorProfilePictureFileName = UrlUtils.extractFileName(url: announcement.author.profilePictureUrl)
        announcementAuthorState = announcement.author.state.rawValue
        announcementAuthorTester = announcement.author.tester
    }
    
    func equals(_ announcement: Announcement) -> Bool {
        announcementId == announcement.id &&
        announcementTitle == announcement.title &&
        announcementContent == announcement.content &&
        announcementDate == announcement.date &&
        announcementState == announcement.state.rawValue &&
        announcementAuthorId == announcement.author.id &&
        announcementAuthorFirstName == announcement.author.firstName &&
        announcementAuthorLastName == announcement.author.lastName &&
        announcementAuthorEmail == announcement.author.email &&
        announcementAuthorSchoolLevel == announcement.author.schoolLevel.rawValue &&
        announcementAuthorAdmin == announcement.author.admin &&
        announcementAuthorProfilePictureFileName == UrlUtils.extractFileName(url: announcement.author.profilePictureUrl) &&
        announcementAuthorState == announcement.author.state.rawValue &&
        announcementAuthorTester == announcement.author.tester
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
