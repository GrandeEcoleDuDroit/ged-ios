import Foundation

let missionFixture = Mission(
    id: "1",
    title: "Randonée en forêt",
    description: "Nous vous convions à une petite randonnée en forêt entre camarade. " +
    "Ce sera l'occasion de se détendre et de profiter du grand air.",
    date: Date(),
    startDate: Date(),
    endDate: Date(),
    schoolLevels: [.level1, .level2, .level3, .level4],
    duration: "Toute la journée",
    managers: [userFixture, userFixture2],
    participants: [usersFixture[2], usersFixture[3]],
    maxParticipants: 10,
    tasks: missionTasksFixture,
    state: .published(imageUrl: "https://plus.unsplash.com/premium_photo-1666874681316-023c0fc7a4be?q=80&w=2340&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
)

let missionsFixture = [
    missionFixture,
    missionFixture.copy {
        $0.id = "2";
        $0.title = "Fête de l'école 🎉";
        $0.description = "Ce week-end aura lieu la fête de l'école. Parents, élèves et enseignants" +
        "sont invités à partager un moment convivial autour de jeux, animations" +
        "et spectacles préparés par les enfants.";
        $0.managers = [userFixture2];
        $0.startDate = Date().plusDays(2);
        $0.endDate = Date().plusDays(5);
        $0.participants = [];
        $0.maxParticipants = 5;
        $0.schoolLevels = [.level1, .level2, .level3, .level4];
        $0.state = .published(imageUrl: "https://plus.unsplash.com/premium_photo-1663839411973-af76a84f5ffe?q=80&w=1287&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
    },
    missionFixture.copy {
        $0.id = "3";
        $0.title = "Recolte de fond pour le voyage en Islande";
        $0.description = """
        Mission consistant à récolter des fonds afin de permettre aux élèves
        de participer à un voyage scolaire en Islande.
        """.trim();
        $0.managers = [userFixture, userFixture2];
        $0.participants = [usersFixture[0], usersFixture[1], usersFixture[3]];
        $0.endDate = Date().plusDays(10);
        $0.maxParticipants = 3;
        $0.schoolLevels = [.level3, .level4];
        $0.tasks = [
            MissionTask(id: "1", value: "Organiser des événements de collecte de fonds (vente de gâteaux, tombola, etc.)"),
            MissionTask(id: "2", value: "Contacter des sponsors ou partenaires potentiels"),
            MissionTask(id: "3", value: "Gérer les inscriptions et les paiements des participants")
        ];
        $0.state = .published(imageUrl: "https://images.unsplash.com/photo-1531366936337-7c912a4589a7?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
    },
    missionFixture.copy {
        $0.id = "4";
        $0.title = "Supervision épreuves";
        $0.description = """
        Supervision des épreuves afin de veiller au bon déroulement et au respect des consignes.
        """.trim();
        $0.startDate = Date().minusDay(2);
        $0.endDate = Date().plusDays(1);
        $0.managers = [userFixture2];
        $0.participants = [usersFixture[0], usersFixture[1], usersFixture[3]];
        $0.maxParticipants = 3;
        $0.schoolLevels = [.level2]
    }
]
