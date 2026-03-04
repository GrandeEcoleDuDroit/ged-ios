struct MissionField {
    struct Local {
        static let missionId = "missionId"
        static let missionTitle = "missionTitle"
        static let missionDescription = "missionDescription"
        static let missionSchoolLevels = "missionSchoolLevels"
        static let missionDate = "missionDate"
        static let missionStartDate = "missionStartDate"
        static let missionEndDate = "missionEndDate"
        static let missionDuration = "missionDuration"
        static let missionManagers = "missionManagers"
        static let missionParticipants = "missionParticipants"
        static let missionMaxParticipants = "missionMaxParticipants"
        static let missionTasks = "missionTasks"
        static let missionImageReference = "missionImageReference"
        static let missionState = "missionState"
    }
    
    struct Remote {
        static let missionId = "MISSION_ID"
        static let missionTitle = "MISSION_TITLE"
        static let missionDescription = "MISSION_DESCRIPTION"
        static let missionSchoolLevels = "MISSION_SCHOOL_LEVELS"
        static let missionDate = "MISSION_DATE"
        static let missionStartDate = "MISSION_START_DATE"
        static let missionEndDate = "MISSION_END_DATE"
        static let missionDuration = "MISSION_DURATION"
        static let missionMaxParticipants = "MISSION_MAX_PARTICIPANTS"
        static let missionTasks = "MISSION_TASKS"
        static let missionImageFileName = "MISSION_IMAGE_FILE_NAME"
        
        struct Inbound {
            static let missionManagers = "MISSION_MANAGERS"
            static let missionParticipants = "MISSION_PARTICIPANTS"
        }
        
        struct Outbound {
            static let missionManagersIds = "MISSION_MANAGER_IDS"
            static let missionParticipantIds = "MISSION_PARTICIPANT_IDS"
        }
    }
}
