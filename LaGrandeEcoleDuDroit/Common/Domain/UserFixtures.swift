let userFixture = User(
    id: "1",
    firstName: "Jean",
    lastName: "Dupont",
    email: "jean.dupont@email.com",
    schoolLevel: SchoolLevel.ged1,
    admin: true
)

let userFixture2 = User(
    id: "2",
    firstName: "Patrick",
    lastName: "Boucher",
    email: "patrick.boucher@email.com",
    schoolLevel: SchoolLevel.ged2
)

let userFixture3 = User(
    id: "3",
    firstName: "Evelyne",
    lastName: "Aubin",
    email: "evelyne.aubin@email.com",
    schoolLevel: SchoolLevel.ged2
)

let usersFixture = [
    userFixture,
    userFixture.copy { $0.id = "2"; $0.firstName = "Marc"; $0.lastName = "Boucher"; $0.profilePictureUrl = "https://avatarfiles.alphacoders.com/375/375590.png" },
    userFixture.copy { $0.id = "3"; $0.firstName = "François"; $0.lastName = "Martin"; $0.profilePictureUrl = "https://avatarfiles.alphacoders.com/330/330775.png" },
    userFixture.copy { $0.id = "4"; $0.firstName = "Pierre"; $0.lastName = "Leclerc"; $0.profilePictureUrl = "https://avatarfiles.alphacoders.com/364/364538.png" },
    userFixture.copy { $0.id = "5"; $0.firstName = "Élodie"; $0.lastName = "LeFevre" },
    userFixture.copy { $0.id = "6"; $0.firstName = "Marianne"; $0.lastName = "LeFevre" },
    userFixture.copy { $0.id = "7"; $0.firstName = "Lucien"; $0.lastName = "Robert" },
    userFixture.copy { $0.id = "8"; $0.firstName = "Marc"; $0.lastName = "Boucher"; $0.profilePictureUrl = "https://avatarfiles.alphacoders.com/375/375590.png" },
    userFixture.copy { $0.id = "9"; $0.firstName = "François"; $0.lastName = "Martin"; $0.profilePictureUrl = "https://avatarfiles.alphacoders.com/330/330775.png" },
    userFixture.copy { $0.id = "10"; $0.firstName = "Pierre"; $0.lastName = "Leclerc"; $0.profilePictureUrl = "https://avatarfiles.alphacoders.com/364/364538.png" },
    userFixture.copy { $0.id = "11"; $0.firstName = "Élodie"; $0.lastName = "LeFevre" },
    userFixture.copy { $0.id = "12"; $0.firstName = "Marianne"; $0.lastName = "LeFevre" },
    userFixture.copy { $0.id = "13"; $0.firstName = "Lucien"; $0.lastName = "Robert" }
]
