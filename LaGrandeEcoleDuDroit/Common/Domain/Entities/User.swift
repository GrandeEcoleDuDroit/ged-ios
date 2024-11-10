struct User: Hashable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var schoolLevel: String
    var isMember: Bool
    var profilePictureUrl: String?
    
    var fullName: String {
        return (firstName + " " + lastName).capitalized
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
