struct FirestoreUser: Codable, Hashable {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: Int
    let admin: Bool
    let profilePictureFileName: String?
    let state: String
    let tester: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case schoolLevel = "schoolLevel"
        case admin = "admin"
        case profilePictureFileName = "profilePictureFileName"
        case state = "state"
        case tester = "tester"
    }
    
    init(
        userId: String,
        firstName: String,
        lastName: String,
        email: String,
        schoolLevel: Int,
        admin: Bool,
        profilePictureFileName: String?,
        state: String,
        tester: Bool
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.schoolLevel = schoolLevel
        self.admin = admin
        self.profilePictureFileName = profilePictureFileName
        self.state = state
        self.tester = tester
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.userId = try container.decode(String.self, forKey: .userId)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.email = try container.decode(String.self, forKey: .email)
        self.schoolLevel = try container.decode(Int.self, forKey: .schoolLevel)
        self.admin = try container.decode(Bool.self, forKey: .admin)
        self.profilePictureFileName = try container.decodeIfPresent(String.self, forKey: .profilePictureFileName)
        self.state = try container.decode(String.self, forKey: .state)
        self.tester = try container.decode(Bool.self, forKey: .tester)
    }
}
