import Foundation
import SwiftUI

struct MissionUtilsPresentation {
    private init() {}
    
    static let maxTitleLength: Int = 100
    static let maxDescriptionLength: Int = 1000
    static let maxParticipantsLength: Int = 4
    static let maxDurationLength: Int = 100
    static let maxTaskLength: Int = 200
    static let missionImageHeight: CGFloat = 200
    static let maxUserItemDisplayed: Int = 5
    
    static let titleFont: Font = .title2
    static let contentFont: Font = .body
    
    static func formatSchoolLevels(schoolLevels: [SchoolLevel]) -> String {
        if schoolLevels.count == SchoolLevel.all.count {
            stringResource(.everyone)
        } else {
            schoolLevels.sorted { $0.number < $1.number }
                .map { $0.rawValue }
                .joined(separator: " - ")
        }
    }
    
    static func formatDate(startDate: Date, endDate: Date) -> String {
        if startDate == endDate {
            startDate.formatDayMonthYear()
        } else {
            startDate.formatDayMonthYear() + " - " + endDate.formatDayMonthYear()
        }
    }
    
    static func formatParticipantNumber(participantsCount: Int, maxParticipants: Int) -> String {
        participantsCount == maxParticipants ? stringResource(.full) : stringResource(.participantNumber, participantsCount,maxParticipants)
    }
    
    static func formatShortParticipantNumber(participantsCount: Int, maxParticipants: Int) -> String {
        participantsCount == maxParticipants ? stringResource(.full) : stringResource(.shortParticipantNumber, participantsCount,maxParticipants)
    }
}
