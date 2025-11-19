struct OutboundRemoteMission: Encodable {
    let missionId: String
    let missionTitle: String
    let missionDescription: String
    let missionSchoolLevels: String
    let missionDate: Int64
    let missionStartDate: Int64
    let missionEndDate: Int64
    let missionDuration: String?
    let missionManagerIds: String
    let missionParticipantIds: String
    let missionMaxParticipants: Int
    let missionTasks: String
    let missionImageFileName: String?
    
    enum CodingKeys: String, CodingKey {
        case missionId = "MISSION_ID"
        case missionTitle = "MISSION_TITLE"
        case missionDescription = "MISSION_DESCRIPTION"
        case missionSchoolLevels = "MISSION_SCHOOL_LEVELS"
        case missionDate = "MISSION_DATE"
        case missionStartDate = "MISSION_START_DATE"
        case missionEndDate = "MISSION_END_DATE"
        case missionDuration = "MISSION_DURATION"
        case missionManagerIds = "MISSION_MANAGER_IDS"
        case missionParticipantIds = "MISSION_PARTICIPANT_IDS"
        case missionMaxParticipants = "MISSION_MAX_PARTICIPANTS"
        case missionTasks = "MISSION_TASKS"
        case missionImageFileName = "MISSION_IMAGE_FILE_NAME"
    }
}

struct InboundRemoteMission: Decodable {
    let missionId: String
    let missionTitle: String
    let missionDescription: String
    let missionSchoolLevels: String?
    let missionDate: Int64
    let missionStartDate: Int64
    let missionEndDate: Int64
    let missionDuration: String?
    let missionManagers: [ServerUser]
    let missionParticipants: [ServerUser]?
    let missionMaxParticipants: Int
    let missionTasks: [RemoteMissionTask]?
    let missionImageFileName: String?
    
    enum CodingKeys: String, CodingKey {
        case missionId = "MISSION_ID"
        case missionTitle = "MISSION_TITLE"
        case missionDescription = "MISSION_DESCRIPTION"
        case missionSchoolLevels = "MISSION_SCHOOL_LEVELS"
        case missionDate = "MISSION_DATE"
        case missionStartDate = "MISSION_START_DATE"
        case missionEndDate = "MISSION_END_DATE"
        case missionDuration = "MISSION_DURATION"
        case missionManagers = "MISSION_MANAGERS"
        case missionParticipants = "MISSION_PARTICIPANTS"
        case missionMaxParticipants = "MISSION_MAX_PARTICIPANTS"
        case missionTasks = "MISSION_TASKS"
        case missionImageFileName = "MISSION_IMAGE_FILE_NAME"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.missionId = try container.decode(String.self, forKey: .missionId)
        self.missionTitle = try container.decode(String.self, forKey: .missionTitle)
        self.missionDescription = try container.decode(String.self, forKey: .missionDescription)
        self.missionSchoolLevels = try container.decodeIfPresent(String.self, forKey: .missionSchoolLevels)
        self.missionDate = try container.decode(Int64.self, forKey: .missionDate)
        self.missionStartDate = try container.decode(Int64.self, forKey: .missionStartDate)
        self.missionEndDate = try container.decode(Int64.self, forKey: .missionEndDate)
        self.missionDuration = try container.decodeIfPresent(String.self, forKey: .missionDuration)
        self.missionManagers = try container.decode([ServerUser].self, forKey: .missionManagers)
        self.missionParticipants = try container.decodeIfPresent([ServerUser].self, forKey: .missionParticipants)
        self.missionMaxParticipants = try container.decode(Int.self, forKey: .missionMaxParticipants)
        self.missionTasks = try container.decodeIfPresent([RemoteMissionTask].self, forKey: .missionTasks)
        self.missionImageFileName = try container.decodeIfPresent(String.self, forKey: .missionImageFileName)
    }
}
