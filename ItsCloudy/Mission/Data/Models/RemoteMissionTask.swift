struct RemoteMissionTask: Codable {
    let missionTaskId: String
    let missionTaskValue: String
    
    enum CodingKeys: String, CodingKey {
        case missionTaskId = "MISSION_TASK_ID"
        case missionTaskValue = "MISSION_TASK_VALUE"
    }
}
