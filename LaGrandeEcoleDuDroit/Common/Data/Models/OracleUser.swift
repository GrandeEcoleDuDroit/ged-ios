struct OracleUser: Codable {
    let userId: String
    let userFirstName: String
    let userLastName: String
    let userEmail: String
    let schoolLevel: String
    let userIsMember: Int
    let userProfilePictureUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "USER_ID"
        case userFirstName = "USER_FIRST_NAME"
        case userLastName = "USER_LAST_NAME"
        case userEmail = "USER_EMAIL"
        case schoolLevel = "USER_SCHOOL_LEVEL"
        case userIsMember = "USER_IS_MEMBER"
        case userProfilePictureUrl = "USER_PROFILE_PICTURE_URL"
    }
}
