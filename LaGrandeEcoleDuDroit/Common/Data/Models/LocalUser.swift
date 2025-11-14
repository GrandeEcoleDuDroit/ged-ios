struct LocalUser: Codable {
    let userId: String
    let userFirstName: String
    let userLastName: String
    let userEmail: String
    let userSchoolLevel: String
    let userAdmin: Bool
    let userProfilePictureFileName: String?
    let userState: String
    let userTester: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userFirstName = "user_first_name"
        case userLastName = "user_last_name"
        case userEmail = "user_email"
        case userSchoolLevel = "user_school_level"
        case userAdmin = "user_admin"
        case userProfilePictureFileName = "user_profile_picture_file_name"
        case userState = "user_state"
        case userTester = "user_tester"
    }
    
    init(
        userId: String,
        userFirstName: String,
        userLastName: String,
        userEmail: String,
        userSchoolLevel: String,
        userAdmin: Bool,
        userProfilePictureFileName: String?,
        userState: String,
        userTester: Bool
    ) {
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
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userFirstName = try container.decode(String.self, forKey: .userFirstName)
        self.userLastName = try container.decode(String.self, forKey: .userLastName)
        self.userEmail = try container.decode(String.self, forKey: .userEmail)
        self.userSchoolLevel = try container.decode(String.self, forKey: .userSchoolLevel)
        self.userAdmin = try container.decode(Bool.self, forKey: .userAdmin)
        self.userProfilePictureFileName = try container.decodeIfPresent(String.self, forKey: .userProfilePictureFileName)
        self.userState = try container.decode(String.self, forKey: .userState)
        self.userTester = try container.decode(Bool.self, forKey: .userTester)
    }
}
