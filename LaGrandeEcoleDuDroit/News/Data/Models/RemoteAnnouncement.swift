struct RemoteAnnouncement: Codable {
    let announcementId: Int
    let announcementTitle: String
    let announcementContent: String
    let announcementDate: Int
    let userId: String
    let userFirstName: String
    let userLastName: String
    let userEmail: String
    let userSchoolLevel: String
    let userIsMember: Int
    let userProfilePictureUrl: String
    
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
        case userProfilePictureUrl = "USER_PROFILE_PICTURE_URL"
    }
}
