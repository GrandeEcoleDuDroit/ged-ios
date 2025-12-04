struct RemoteAddMissionParticipant: Encodable {
    let missionId: String
    let missionSchoolLevels: [Int]
    let missionMaxParticipants: Int
    let missionParticipantsNumber: Int
    let userId: String
    let userSchoolLevel: Int
    
    enum CodingKeys: String, CodingKey {
        case missionId = "MISSION_ID"
        case missionSchoolLevels = "MISSION_SCHOOL_LEVELS"
        case missionMaxParticipants = "MISSION_MAX_PARTICIPANTS"
        case missionParticipantsNumber = "MISSION_PARTICIPANTS_NUMBER"
        case userId = "USER_ID"
        case userSchoolLevel = "USER_SCHOOL_LEVEL"
    }
}
