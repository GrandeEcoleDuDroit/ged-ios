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
    var userIsDeleted: Int
    
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
        case userIsDeleted = "USER_IS_DELETED"
    }
    
    init(
        announcementId: String,
        announcementTitle: String?,
        announcementContent: String,
        announcementDate: Int64,
        userId: String,
        userFirstName: String,
        userLastName: String,
        userEmail: String,
        userSchoolLevel: String,
        userIsMember: Int,
        userProfilePictureFileName: String?,
        userIsDeleted: Int
    ) {
        self.announcementId = announcementId
        self.announcementTitle = announcementTitle
        self.announcementContent = announcementContent
        self.announcementDate = announcementDate
        self.userId = userId
        self.userFirstName = userFirstName
        self.userLastName = userLastName
        self.userEmail = userEmail
        self.userSchoolLevel = userSchoolLevel
        self.userIsMember = userIsMember
        self.userProfilePictureFileName = userProfilePictureFileName
        self.userIsDeleted = userIsDeleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        announcementId = try container.decode(String.self, forKey: .announcementId)
        announcementTitle = try container.decodeIfPresent(String.self, forKey: .announcementTitle)
        announcementContent = try container.decode(String.self, forKey: .announcementContent)
        announcementDate = try container.decode(Int64.self, forKey: .announcementDate)
        userId = try container.decode(String.self, forKey: .userId)
        userFirstName = try container.decode(String.self, forKey: .userFirstName)
        userLastName = try container.decode(String.self, forKey: .userLastName)
        userEmail = try container.decode(String.self, forKey: .userEmail)
        userSchoolLevel = try container.decode(String.self, forKey: .userSchoolLevel)
        userIsMember = try container.decode(Int.self, forKey: .userIsMember)
        userProfilePictureFileName = try container.decodeIfPresent(String.self, forKey: .userProfilePictureFileName)
        userIsDeleted = try container.decodeIfPresent(Int.self, forKey: .userIsDeleted) ?? 0
    }
}
