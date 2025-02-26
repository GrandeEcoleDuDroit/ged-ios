struct FirestoreUser: Codable, Hashable {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: String
    let isMember: Bool
    let profilePictureFileName: String?
    let isOnline: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case schoolLevel = "school_level"
        case isMember = "is_member"
        case profilePictureFileName = "profile_picture_file_name"
        case isOnline = "is_online"
    }
}
