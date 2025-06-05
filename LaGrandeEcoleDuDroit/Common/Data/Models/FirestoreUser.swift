struct FirestoreUser: Codable, Hashable {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: String
    let isMember: Bool
    let profilePictureFileName: String?
    
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
    }
}
