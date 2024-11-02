struct FirestoreUser: Codable {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: String
    let isMember: Bool
    let profilePictureUrl: String?
    let isOnline: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case schoolLevel = "school_level"
        case isMember = "is_member"
        case profilePictureUrl = "profile_picture_url"
        case isOnline = "is_online"
    }
}
