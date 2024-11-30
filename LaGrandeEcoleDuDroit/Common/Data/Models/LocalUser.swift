struct LocalUser: Codable {
    let userId: String
    let userFirstName: String
    let userLastName: String
    let userEmail: String
    let userSchoolLevel: String
    let userIsMember: Bool
    let userProfilePictureUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userFirstName = "user_first_name"
        case userLastName = "user_last_name"
        case userEmail = "user_email"
        case userSchoolLevel = "user_school_level"
        case userIsMember = "user_is_member"
        case userProfilePictureUrl = "user_profile_picture_url"
    }
}
