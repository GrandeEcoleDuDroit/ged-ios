struct FirestoreUser: Codable, Hashable {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: String
    let isMember: Bool
    let profilePictureFileName: String?
    let isDeleted: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case schoolLevel = "schoolLevel"
        case isMember = "isMember"
        case profilePictureFileName = "profilePictureFileName"
        case isDeleted = "isDeleted"
    }
    
    init(
        userId: String,
        firstName: String,
        lastName: String,
        email: String,
        schoolLevel: String,
        isMember: Bool,
        profilePictureFileName: String?,
        isDeleted: Bool
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.schoolLevel = schoolLevel
        self.isMember = isMember
        self.profilePictureFileName = profilePictureFileName
        self.isDeleted = isDeleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.userId = try container.decode(String.self, forKey: .userId)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.email = try container.decode(String.self, forKey: .email)
        self.schoolLevel = try container.decode(String.self, forKey: .schoolLevel)
        self.isMember = try container.decode(Bool.self, forKey: .isMember)
        self.profilePictureFileName = try container.decodeIfPresent(String.self, forKey: .profilePictureFileName)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
    }
}
