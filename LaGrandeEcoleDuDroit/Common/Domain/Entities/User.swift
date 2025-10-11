struct User: Codable, Hashable, Identifiable, Copyable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var schoolLevel: SchoolLevel
    var isMember: Bool
    var profilePictureUrl: String?
    
    var fullName: String {
        firstName + " " + lastName
    }
}

enum SchoolLevel: String, CaseIterable, Identifiable, Codable {
    case ged1 = "GED 1"
    case ged2 = "GED 2"
    case ged3 = "GED 3"
    case ged4 = "GED 4"
    
    var id: String { self.rawValue }
}
