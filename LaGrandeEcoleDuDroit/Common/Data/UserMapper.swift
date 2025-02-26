class UserMapper {
    static func toFirestoreUser(user: User) -> FirestoreUser {
        FirestoreUser(
            userId: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            schoolLevel: user.schoolLevel,
            isMember: user.isMember,
            profilePictureFileName: getFileNameFromUrl(url: user.profilePictureUrl),
            isOnline: false
        )
    }
    
    static func toOracleUser(user: User) -> OracleUser {
        OracleUser(
            userId: user.id,
            userFirstName: user.firstName,
            userLastName: user.lastName,
            userEmail: user.email,
            schoolLevel: user.schoolLevel,
            userIsMember: user.isMember ? 1 : 0,
            profilePictureFileName: getFileNameFromUrl(url: user.profilePictureUrl)
        )
    }
    
    static func toLocalUser(user: User) -> LocalUser {
        LocalUser(
            userId: user.id,
            userFirstName: user.firstName,
            userLastName: user.lastName,
            userEmail: user.email,
            userSchoolLevel: user.schoolLevel,
            userIsMember: user.isMember,
            profilePictureUrl: user.profilePictureUrl
        )
    }
    
    static func toDomain(localUser: LocalUser) -> User {
        User(
            id: localUser.userId,
            firstName: localUser.userFirstName,
            lastName: localUser.userLastName,
            email: localUser.userEmail,
            schoolLevel: localUser.userSchoolLevel,
            isMember: localUser.userIsMember,
            profilePictureUrl: localUser.profilePictureUrl
        )
    }
    
    static func toDomain(firestoreUser: FirestoreUser) -> User {
        User(
            id: firestoreUser.userId,
            firstName: firestoreUser.firstName,
            lastName: firestoreUser.lastName,
            email: firestoreUser.email,
            schoolLevel: firestoreUser.schoolLevel,
            isMember: firestoreUser.isMember,
            profilePictureUrl: formatProfilePictureUrl(fileName: firestoreUser.profilePictureFileName)
        )
    }
    
    static func formatProfilePictureUrl(fileName: String?) -> String? {
        guard let fileName = fileName else { return nil }
        return "https://objectstorage.eu-paris-1.oraclecloud.com/n/ax5bfuffglob/b/bucket-gedoise/o/\(fileName)"
    }
    
    static func getFileNameFromUrl(url: String?) -> String? {
        url?.components(separatedBy: "/").last
    }
}
