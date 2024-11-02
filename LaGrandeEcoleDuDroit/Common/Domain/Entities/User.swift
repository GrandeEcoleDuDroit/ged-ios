struct User {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: String
    let isMember: Bool
    let profilePictureUrl: String?
    
    var fullName: String {
        return (firstName + " " + lastName).capitalized
    }
}
