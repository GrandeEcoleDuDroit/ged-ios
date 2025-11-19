struct OutbondRemoteAnnouncement: Codable {
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

struct InboundRemoteAnnouncement: Codable {
    var announcementId: String
    var announcementTitle: String?
    var announcementContent: String
    var announcementDate: Int64
    var userId: String
    var userFirstName: String
    var userLastName: String
    var userEmail: String
    var userSchoolLevel: Int
    var userAdmin: Int
    var userProfilePictureFileName: String?
    var userState: String
    var userTester: Int
    
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
        case userAdmin = "USER_ADMIN"
        case userProfilePictureFileName = "USER_PROFILE_PICTURE_FILE_NAME"
        case userState = "USER_STATE"
        case userTester = "USER_TESTER"
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
        userSchoolLevel: Int,
        userAdmin: Int,
        userProfilePictureFileName: String?,
        userState: String,
        userTester: Int
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
        self.userAdmin = userAdmin
        self.userProfilePictureFileName = userProfilePictureFileName
        self.userState = userState
        self.userTester = userTester
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
        userSchoolLevel = try container.decode(Int.self, forKey: .userSchoolLevel)
        userAdmin = try container.decode(Int.self, forKey: .userAdmin)
        userProfilePictureFileName = try container.decodeIfPresent(String.self, forKey: .userProfilePictureFileName)
        userState = try container.decode(String.self, forKey: .userState)
        userTester = try container.decode(Int.self, forKey: .userTester)
    }
}
