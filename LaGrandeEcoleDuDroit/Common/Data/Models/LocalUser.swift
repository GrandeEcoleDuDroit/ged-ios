struct LocalUser: Codable {
    let userId: String
    let userFirstName: String
    let userLastName: String
    let userEmail: String
    let userSchoolLevel: String
    let userIsMember: Bool
    let userProfilePictureFileName: String?
    let userIsDeleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userFirstName = "user_first_name"
        case userLastName = "user_last_name"
        case userEmail = "user_email"
        case userSchoolLevel = "user_school_level"
        case userIsMember = "user_is_member"
        case userProfilePictureFileName = "user_profile_picture_file_name"
        case userIsDeleted = "user_is_deleted"
    }
    
    init(
        userId: String,
        userFirstName: String,
        userLastName: String,
        userEmail: String,
        userSchoolLevel: String,
        userIsMember: Bool,
        userProfilePictureFileName: String?,
        userIsDeleted: Bool
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
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userFirstName = try container.decode(String.self, forKey: .userFirstName)
        self.userLastName = try container.decode(String.self, forKey: .userLastName)
        self.userEmail = try container.decode(String.self, forKey: .userEmail)
        self.userSchoolLevel = try container.decode(String.self, forKey: .userSchoolLevel)
        self.userIsMember = try container.decode(Bool.self, forKey: .userIsMember)
        self.userProfilePictureFileName = try container.decodeIfPresent(String.self, forKey: .userProfilePictureFileName)
        self.userIsDeleted = try container.decodeIfPresent(Bool.self, forKey: .userIsDeleted) ?? false
    }
}
