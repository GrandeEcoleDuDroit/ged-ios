extension FirestoreUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: SchoolLevel(rawValue: schoolLevel) ?? .ged1,
            isMember: isMember,
            profilePictureFileName: profilePictureFileName
        )
    }
}

extension User {
    func toOracleUser() -> OracleUser {
        OracleUser(
            userId: id,
            userFirstName: firstName,
            userLastName: lastName,
            userEmail: email,
            schoolLevel: schoolLevel.rawValue,
            userIsMember: isMember ? 1 : 0,
            profilePictureFileName: UrlUtils.getFileNameFromUrl(url: profilePictureFileName)
        )
    }
    
    func toFirestoreUser() -> FirestoreUser {
        FirestoreUser(
            userId: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: schoolLevel.rawValue,
            isMember: isMember,
            profilePictureFileName: UrlUtils.getFileNameFromUrl(url: profilePictureFileName)
        )
    }
    
    func toLocal() -> LocalUser {
        LocalUser(
            userId: id,
            userFirstName: firstName,
            userLastName: lastName,
            userEmail: email,
            userSchoolLevel: schoolLevel.rawValue,
            userIsMember: isMember,
            profilePictureFileName: profilePictureFileName
        )
    }
}

extension LocalUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: userFirstName,
            lastName: userLastName,
            email: userEmail,
            schoolLevel: SchoolLevel.init(rawValue: userSchoolLevel)!,
            isMember: userIsMember,
            profilePictureFileName: profilePictureFileName
        )
    }
}
