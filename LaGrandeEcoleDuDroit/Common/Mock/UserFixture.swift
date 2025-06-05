let userFixture = User(
    id: "1",
    firstName: "Jean",
    lastName: "Dupont",
    email: "jean.dupont@email.com",
    schoolLevel: SchoolLevel.ged1,
    isMember: true,
    profilePictureFileName: nil
)

let userFixture2 = User(
    id: "2",
    firstName: "Patrick",
    lastName: "Boucher",
    email: "patrick.boucher@email.com",
    schoolLevel: SchoolLevel.ged2,
    isMember: false,
    profilePictureFileName: nil
)

let userFixture3 = User(
    id: "3",
    firstName: "Evelyne",
    lastName: "Aubin",
    email: "evelyne.aubin@email.com",
    schoolLevel: SchoolLevel.ged2,
    isMember: false,
    profilePictureFileName: nil
)

let usersFixture = [
    userFixture,
    userFixture.with(id: "2", firstName: "Marc", lastName: "Boucher", profilePictureFileName: "https://avatarfiles.alphacoders.com/375/375590.png"),
    userFixture.with(id: "3", firstName: "François", lastName: "Martin", profilePictureFileName: "https://avatarfiles.alphacoders.com/330/330775.png"),
    userFixture.with(id: "4", firstName: "Pierre", lastName: "Leclerc", profilePictureFileName: "https://avatarfiles.alphacoders.com/364/364538.png"),
    userFixture.with(id: "5", firstName: "Élodie", lastName: "LeFevre"),
    userFixture.with(id: "6", firstName: "Marianne", lastName: "LeFevre"),
    userFixture.with(id: "7", firstName: "Lucien", lastName: "Robert"),
    userFixture.with(id: "8", firstName: "Marc", lastName: "Boucher", profilePictureFileName: "https://avatarfiles.alphacoders.com/375/375590.png"),
    userFixture.with(id: "9", firstName: "François", lastName: "Martin", profilePictureFileName: "https://avatarfiles.alphacoders.com/330/330775.png"),
    userFixture.with(id: "10", firstName: "Pierre", lastName: "Leclerc", profilePictureFileName: "https://avatarfiles.alphacoders.com/364/364538.png"),
    userFixture.with(id: "11", firstName: "Élodie", lastName: "LeFevre"),
    userFixture.with(id: "12", firstName: "Marianne", lastName: "LeFevre"),
    userFixture.with(id: "13", firstName: "Lucien", lastName: "Robert"),
]
