import Foundation

let missionFixture = Mission(
    id: "1",
    title: "Long title example to test ellipsis in the mission card component",
    description: """
        This is the description of the first mission. It can be quite long and detailed. It provides all the necessary information about the mission.
        The mission aims to help students improve their skills and gain practical experience in various fields. Participants will have the opportunity to work on real projects and collaborate with professionals.
        We encourage all interested students to apply and take advantage of this unique learning experience.
    """.trimmingCharacters(in: .whitespacesAndNewlines),
    date: Date(),
    startDate: Date(),
    endDate: Date().plusDays(1),
    schoolLevels: [.ged1, .ged2, .ged3],
    duration: "Once a week",
    managers: [userFixture],
    participants: [userFixture2],
    maxParticipants: 20,
    tasks: missionTasksFixture,
    state: .published()
)

let missionsFixture = [
    missionFixture,
    missionFixture.copy {
        $0.id = "2";
        $0.title = "Second mission";
        $0.description = "A short description for the second mission.";
        $0.managers = [userFixture2];
        $0.participants = [userFixture];
        $0.schoolLevels = [.ged1]
    },
    missionFixture.copy {
        $0.id = "3";
        $0.title = "Third mission";
        $0.description = "The third mission has a medium-length description to provide some context.";
        $0.managers = [userFixture2, userFixture];
        $0.participants = [userFixture, userFixture];
        $0.schoolLevels = []
    },
    missionFixture.copy {
        $0.id = "4";
        $0.title = "Fourth mission";
        $0.description = "The fourth mission has a medium-length description to provide some context.";
        $0.managers = [userFixture2, userFixture];
        $0.participants = [userFixture, userFixture];
        $0.schoolLevels = [.ged1, .ged2, .ged3, .ged4]
    }
]
