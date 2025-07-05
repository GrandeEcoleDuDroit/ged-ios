struct RemoteAnnouncement: Codable {
    var announcementId: String
    var announcementTitle: String?
    var announcementContent: String
    var announcementDate: Int64
    var userId: String
    
    enum CodingKeys: String, CodingKey {
        case announcementId = "ANNOUNCEMENT_ID"
        case announcementTitle = "ANNOUNCEMENT_TITLE"
        case announcementContent = "ANNOUNCEMENT_CONTENT"
        case announcementDate = "ANNOUNCEMENT_DATE"
        case userId = "USER_ID"
    }
}

struct RemoteAnnouncementWithUser: Codable {
    var announcementId: String
    var announcementTitle: String?
    var announcementContent: String
    var announcementDate: Int64
    var userId: String
    var userFirstName: String
    var userLastName: String
    var userEmail: String
    var userSchoolLevel: String
    var userIsMember: Int
    var userProfilePictureFileName: String?
    
    enum CodingKeys: String, CodingKey {
        case announcementId = "ANNOUNCEMENT_ID"
        case announcementTitle = "ANNOUNCEMENT_TITLE"
        case announcementContent = "ANNOUNCEMENT_CONTENT"
        case announcementDate = "ANNOUNCEMENT_DATE"
        case userId = "USER_ID"
        case userFirstName = "USER_FIRST_NAME"
        case userLastName = "USER_LAST_NAME"
        case userEmail = "USER_EMAIL"
        case userSchoolLevel = "USER_SCHOOL_LEVEL"
        case userIsMember = "USER_IS_MEMBER"
        case userProfilePictureFileName = "USER_PROFILE_PICTURE_FILE_NAME"
    }
}
