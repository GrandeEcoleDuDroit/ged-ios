struct ServerUser: Codable {
    let userId: String
    let userFirstName: String
    let userLastName: String
    let userEmail: String
    let userSchoolLevel: Int
    let userAdmin: Int
    let userProfilePictureFileName: String?
    let userState: String
    let userTester: Int
    
    enum CodingKeys: String, CodingKey {
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

        self.userId = try container.decode(String.self, forKey: .userId)
        self.userFirstName = try container.decode(String.self, forKey: .userFirstName)
        self.userLastName = try container.decode(String.self, forKey: .userLastName)
        self.userEmail = try container.decode(String.self, forKey: .userEmail)
        self.userSchoolLevel = try container.decode(Int.self, forKey: .userSchoolLevel)
        self.userAdmin = try container.decode(Int.self, forKey: .userAdmin)
        self.userProfilePictureFileName = try container.decodeIfPresent(String.self, forKey: .userProfilePictureFileName)
        self.userState = try container.decode(String.self, forKey: .userState)
        self.userTester = try container.decode(Int.self, forKey: .userTester)
    }
}
