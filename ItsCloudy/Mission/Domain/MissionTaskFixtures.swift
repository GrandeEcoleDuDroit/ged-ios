let missionTaskFixture = MissionTask(id: "1", value: "Task 1")

let missionTasksFixture = [
    missionTaskFixture,
    missionTaskFixture.copy { $0.id = "2"; $0.value = "Task 2" },
    missionTaskFixture.copy { $0.id = "3"; $0.value = "Task 3" }
]
