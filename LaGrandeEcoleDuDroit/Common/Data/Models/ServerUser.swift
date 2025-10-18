struct ServerUser: Codable {
    let userId: String
    let userFirstName: String
    let userLastName: String
    let userEmail: String
    let userSchoolLevel: String
    let userIsMember: Int
    let userProfilePictureFileName: String?
    let userIsDeleted: Int
    
    enum CodingKeys: String, CodingKey {
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
        userId: String,
        userFirstName: String,
        userLastName: String,
        userEmail: String,
        userSchoolLevel: String,
        userIsMember: Int,
        userProfilePictureFileName: String?,
        userIsDeleted: Int
    ) {
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

        self.userId = try container.decode(String.self, forKey: .userId)
        self.userFirstName = try container.decode(String.self, forKey: .userFirstName)
        self.userLastName = try container.decode(String.self, forKey: .userLastName)
        self.userEmail = try container.decode(String.self, forKey: .userEmail)
        self.userSchoolLevel = try container.decode(String.self, forKey: .userSchoolLevel)
        self.userIsMember = try container.decode(Int.self, forKey: .userIsMember)
        self.userProfilePictureFileName = try container.decodeIfPresent(String.self, forKey: .userProfilePictureFileName)
        self.userIsDeleted = try container.decodeIfPresent(Int.self, forKey: .userIsDeleted) ?? 0
    }
}
