extension User {
    func toServerUser() -> ServerUser {
        ServerUser(
            userId: id,
            userFirstName: firstName.lowercased(),
            userLastName: lastName.lowercased(),
            userEmail: email,
            userSchoolLevel: schoolLevel.number,
            userAdmin: admin ? 1 : 0,
            userProfilePictureFileName: UrlUtils.extractFileNameFromUrl(url: profilePictureUrl),
            userState: state.rawValue,
            userTester: tester ? 1 : 0
        )
    }
    
    func toFirestoreUser() -> FirestoreUser {
        FirestoreUser(
            userId: id,
            firstName: firstName.lowercased(),
            lastName: lastName.lowercased(),
            email: email,
            schoolLevel: schoolLevel.number,
            admin: admin,
            profilePictureFileName: UrlUtils.extractFileNameFromUrl(url: profilePictureUrl),
            state: state.rawValue,
            tester: tester
        )
    }
    
    func toLocal() -> LocalUser {
        LocalUser(
            userId: id,
            userFirstName: firstName.lowercased(),
            userLastName: lastName.lowercased(),
            userEmail: email,
            userSchoolLevel: schoolLevel.rawValue,
            userAdmin: admin,
            userProfilePictureFileName: UrlUtils.extractFileNameFromUrl(url: profilePictureUrl),
            userState: state.rawValue,
            userTester: tester
        )
    }
}

extension LocalUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: userFirstName.uppercaseFirstLetter(),
            lastName: userLastName.uppercaseFirstLetter(),
            email: userEmail,
            schoolLevel: SchoolLevel.init(rawValue: userSchoolLevel)!,
            admin: userAdmin,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: userProfilePictureFileName),
        )
    }
}

extension FirestoreUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: firstName.uppercaseFirstLetter(),
            lastName: lastName.uppercaseFirstLetter(),
            email: email,
            schoolLevel: SchoolLevel.fromNumber(schoolLevel),
            admin: admin,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: profilePictureFileName),
            state: User.UserState(rawValue: state) ?? .active,
            tester: tester
        )
    }
}

extension ServerUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: userFirstName,
            lastName: userLastName,
            email: userEmail,
            schoolLevel: SchoolLevel.fromNumber(userSchoolLevel),
            admin: userAdmin == 1,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: userProfilePictureFileName),
            state: User.UserState(rawValue: userState) ?? .active,
            tester: userTester == 1
        )
    }
}

extension UserReport {
    func toRemote() -> RemoteUserReport {
        RemoteUserReport(
            userId: userId,
            userInfo: userInfo.toRemote(),
            reporterInfo: reporterInfo.toRemote(),
            reason: reason.rawValue
        )
    }
}

extension UserReport.UserInfo {
    func toRemote() -> RemoteUserReport.RemoteUserInfo {
        RemoteUserReport.RemoteUserInfo(
            fullName: fullName,
            email: email
        )
    }
}
