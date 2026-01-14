let userFixture = User(
    id: "1",
    firstName: "Jean",
    lastName: "Dupont",
    email: "jean.dupont@email.com",
    schoolLevel: SchoolLevel.ged1,
    admin: true, 
    profilePictureUrl: "https://images.unsplash.com/photo-1545570503-b656623ef132?q=80&w=1364&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
)

let userFixture2 = User(
    id: "2",
    firstName: "Patrick",
    lastName: "Boucher",
    email: "patrick.boucher@email.com",
    schoolLevel: SchoolLevel.ged2,
    profilePictureUrl: "https://cdn.pixabay.com/photo/2023/07/25/19/27/ai-generated-8149775_1280.jpg"
)

let userFixture3 = User(
    id: "3",
    firstName: "Evelyne",
    lastName: "Aubin",
    email: "evelyne.aubin@email.com",
    schoolLevel: SchoolLevel.ged2,
    profilePictureUrl: "https://images.unsplash.com/photo-1596854307809-6e754c522f95?q=80&w=1760&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
)

let usersFixture = [
    userFixture,
    userFixture.copy {
        $0.id = "2";
        $0.firstName = "François";
        $0.lastName = "Martin";
        $0.profilePictureUrl = "https://images.unsplash.com/photo-1459356979461-dae1b8dcb702?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    },
    userFixture.copy {
        $0.id = "3";
        $0.firstName = "Sonia";
        $0.lastName = "Delaunay";
        $0.profilePictureUrl = "https://images.unsplash.com/photo-1552728089-57bdde30beb3?q=80&w=1325&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    },
    userFixture.copy {
        $0.id = "4";
        $0.firstName = "Pedro";
        $0.lastName = "Sanchez";
        $0.profilePictureUrl = "https://images.unsplash.com/photo-1563313003-a39f4d54499d?q=80&w=1335&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    },
    userFixture.copy {
        $0.id = "5";
        $0.firstName = "Élodie";
        $0.lastName = "LeFevre";
        $0.profilePictureUrl = "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?q=80&w=1286&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    },
    userFixture.copy {
        $0.id = "6";
        $0.firstName = "Rémy";
        $0.lastName = "Roy";
        $0.profilePictureUrl = "https://plus.unsplash.com/premium_photo-1670596899123-c4c67735d77a?q=80&w=2340&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    },
    userFixture.copy {
        $0.id = "7";
        $0.firstName = "Louis";
        $0.lastName = "Leclerc";
        $0.profilePictureUrl = "https://images.unsplash.com/photo-1745758278435-db28ef18d6b2?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
    }
]
