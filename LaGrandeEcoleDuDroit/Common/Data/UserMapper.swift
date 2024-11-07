class UserMapper {
    static func toFirestoreUser(user: User) -> FirestoreUser {
        FirestoreUser(
            userId: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            schoolLevel: user.schoolLevel,
            isMember: user.isMember,
            profilePictureUrl: user.profilePictureUrl,
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
            userProfilePictureUrl: user.profilePictureUrl
        )
    }
    
    static func toUserLocal(user: User) -> UserLocal {
        UserLocal(
            userId: user.id,
            userFirstName: user.firstName,
            userLastName: user.lastName,
            userEmail: user.email,
            userSchoolLevel: user.schoolLevel,
            userIsMember: user.isMember,
            userProfilePictureUrl: user.profilePictureUrl
        )
    }
    
    static func toDomain(userLocal: UserLocal) -> User {
        User(
            id: userLocal.userId,
            firstName: userLocal.userFirstName,
            lastName: userLocal.userLastName,
            email: userLocal.userEmail,
            schoolLevel: userLocal.userSchoolLevel,
            isMember: userLocal.userIsMember,
            profilePictureUrl: userLocal.userProfilePictureUrl
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
            profilePictureUrl: firestoreUser.profilePictureUrl
        )
    }
}
