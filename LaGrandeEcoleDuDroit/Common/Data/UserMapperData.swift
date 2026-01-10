extension User {
    func toOracleUser() -> OracleUser {
        OracleUser(
            userId: id,
            userFirstName: firstName.lowercased(),
            userLastName: lastName.lowercased(),
            userEmail: email,
            userSchoolLevel: schoolLevel.number,
            userAdmin: admin ? 1 : 0,
            userProfilePictureFileName: UserUtils.ProfilePicture.getFileName(url: profilePictureUrl),
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
            profilePictureFileName: UserUtils.ProfilePicture.getFileName(url: profilePictureUrl),
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
            userProfilePictureFileName: UserUtils.ProfilePicture.getFileName(url: profilePictureUrl),
            userState: state.rawValue,
            userTester: tester
        )
    }
}

extension LocalUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: UserUtils.Name.formatName(userFirstName),
            lastName: UserUtils.Name.formatName(userLastName),
            email: userEmail,
            schoolLevel: SchoolLevel.init(rawValue: userSchoolLevel)!,
            admin: userAdmin,
            profilePictureUrl: UserUtils.ProfilePicture.getUrl(fileName: userProfilePictureFileName),
            state: User.UserState(rawValue: userState) ?? .active,
            tester: userTester
        )
    }
}

extension FirestoreUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: UserUtils.Name.formatName(firstName),
            lastName: UserUtils.Name.formatName(lastName),
            email: email,
            schoolLevel: SchoolLevel.fromNumber(schoolLevel),
            admin: admin,
            profilePictureUrl: UserUtils.ProfilePicture.getUrl(fileName: profilePictureFileName),
            state: User.UserState(rawValue: state) ?? .active,
            tester: tester
        )
    }
}

extension OracleUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: UserUtils.Name.formatName(userFirstName),
            lastName: UserUtils.Name.formatName(userLastName),
            email: userEmail,
            schoolLevel: SchoolLevel.fromNumber(userSchoolLevel),
            admin: userAdmin == 1,
            profilePictureUrl: UserUtils.ProfilePicture.getUrl(fileName: userProfilePictureFileName),
            state: User.UserState(rawValue: userState) ?? .active,
            tester: userTester == 1
        )
    }
}

extension UserReport {
    func toRemote() -> RemoteUserReport {
        RemoteUserReport(
            userId: userId,
            reportedUser: reportedUser.toRemote(),
            reporter: reporterInfo.toRemote(),
            reason: reason.rawValue
        )
    }
}

private extension UserReport.ReportedUser {
    func toRemote() -> RemoteUserReport.RemoteReportedUser {
        RemoteUserReport.RemoteReportedUser(
            fullName: fullName,
            email: email
        )
    }
}

private extension UserReport.Reporter {
    func toRemote() -> RemoteUserReport.RemoteReporter {
        RemoteUserReport.RemoteReporter(
            fullName: fullName,
            email: email
        )
    }
}
