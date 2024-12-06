let userFixture = User(
    id: "1",
    firstName: "Jean",
    lastName: "Dupont",
    email: "jean.dupon@email.com",
    schoolLevel: "GED 1",
    isMember: true
)

let usersFixture = [
    userFixture,
    userFixture.copy(id: "2", firstName: "Marc", lastName: "Boucher", profilePictureUrl: "https://avatarfiles.alphacoders.com/375/375590.png"),
    userFixture.copy(id: "3", firstName: "François", lastName: "Martin", profilePictureUrl: "https://avatarfiles.alphacoders.com/330/330775.png"),
    userFixture.copy(id: "4", firstName: "Pierre", lastName: "Leclerc", profilePictureUrl: "https://avatarfiles.alphacoders.com/364/364538.png"),
    userFixture.copy(id: "5", firstName: "Élodie", lastName: "LeFevre"),
    userFixture.copy(id: "6", firstName: "Marianne", lastName: "LeFevre"),
    userFixture.copy(id: "7", firstName: "Lucien", lastName: "Robert"),
    userFixture.copy(id: "8", firstName: "Marc", lastName: "Boucher", profilePictureUrl: "https://avatarfiles.alphacoders.com/375/375590.png"),
    userFixture.copy(id: "9", firstName: "François", lastName: "Martin", profilePictureUrl: "https://avatarfiles.alphacoders.com/330/330775.png"),
    userFixture.copy(id: "10", firstName: "Pierre", lastName: "Leclerc", profilePictureUrl: "https://avatarfiles.alphacoders.com/364/364538.png"),
    userFixture.copy(id: "11", firstName: "Élodie", lastName: "LeFevre"),
    userFixture.copy(id: "12", firstName: "Marianne", lastName: "LeFevre"),
    userFixture.copy(id: "13", firstName: "Lucien", lastName: "Robert"),
]
