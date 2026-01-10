import Foundation

enum MissionError: Error {
    case schoolLevelNotAllowed
    case maxParticipantsNumberReached
    
    var code: String {
        switch self {
            case .schoolLevelNotAllowed: "SCHOOL_LEVEL_NOT_ALLOWED"
            case .maxParticipantsNumberReached: "MAX_PARTICIPANTS_NUMBER_REACHED"
        }
    }
}

extension MissionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .schoolLevelNotAllowed: stringResource(.schoolLevelNotAllowedError)
            case .maxParticipantsNumberReached: stringResource(.maxParticipantNumberReachedError)
        }
    }
}
