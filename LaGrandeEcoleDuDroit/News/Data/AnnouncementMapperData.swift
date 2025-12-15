import Foundation
import CoreData

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
              let authorFirstName = announcementAuthorFirstName?.userNameFormatting(),
              let authorLastName = announcementAuthorLastName?.userNameFormatting(),
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
            profilePictureUrl: UserUtils.ProfilePictureFile.url(fileName: announcementAuthorProfilePictureFileName)
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
        announcementAuthorFirstName = announcement.author.firstName.lowercased()
        announcementAuthorLastName = announcement.author.lastName.lowercased()
        announcementAuthorEmail = announcement.author.email
        announcementAuthorSchoolLevel = announcement.author.schoolLevel.rawValue
        announcementAuthorAdmin = announcement.author.admin
        announcementAuthorProfilePictureFileName = UserUtils.ProfilePictureFile.getFileName(url: announcement.author.profilePictureUrl)
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
        announcementAuthorFirstName == announcement.author.firstName.lowercased() &&
        announcementAuthorLastName == announcement.author.lastName.lowercased() &&
        announcementAuthorEmail == announcement.author.email &&
        announcementAuthorSchoolLevel == announcement.author.schoolLevel.rawValue &&
        announcementAuthorAdmin == announcement.author.admin &&
        announcementAuthorProfilePictureFileName == UserUtils.ProfilePictureFile.getFileName(url: announcement.author.profilePictureUrl) &&
        announcementAuthorState == announcement.author.state.rawValue &&
        announcementAuthorTester == announcement.author.tester
    }
}

extension InboundRemoteAnnouncement {
    func toAnnouncement() -> Announcement {
        let user = User(
            id: userId,
            firstName: userFirstName.userNameFormatting(),
            lastName: userLastName.userNameFormatting(),
            email: userEmail,
            schoolLevel: SchoolLevel.fromNumber(userSchoolLevel),
            admin: userAdmin == 1,
            profilePictureUrl: UserUtils.ProfilePictureFile.url(fileName: userProfilePictureFileName),
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

extension AnnouncementReport {
    func toRemote() -> RemoteAnnouncementReport {
        RemoteAnnouncementReport(
            announcementId: announcementId,
            author: author.toRemote(),
            reporter: reporter.toRemote(),
            reason: reason.rawValue
        )
    }
}

private extension AnnouncementReport.Author {
    func toRemote() -> RemoteAnnouncementReport.RemoteAuthor {
        RemoteAnnouncementReport.RemoteAuthor(
            fullName: fullName,
            email: email
        )
    }
}

private extension AnnouncementReport.Reporter {
    func toRemote() -> RemoteAnnouncementReport.RemoteReporter {
        RemoteAnnouncementReport.RemoteReporter(
            fullName: fullName,
            email: email
        )
    }
}
