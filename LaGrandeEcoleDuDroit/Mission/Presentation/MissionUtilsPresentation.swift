import Foundation
import SwiftUI

struct MissionUtilsPresentation {
    private init() {}
    
    static let maxTitleLength: Int = 100
    static let maxDescriptionLength: Int = 1000
    static let maxDurationLength: Int = 200
    static let maxTaskLength: Int = 300
    static let missionImageHeight: CGFloat = 200
    
    static let titleFont: Font = .title
    static let descriptionFont: Font = .body
    static let contentFont: Font = .callout
    
    static func formatSchoolLevels(schoolLevels: [SchoolLevel]) -> String {
        if schoolLevels.count == SchoolLevel.allCases.count || schoolLevels.isEmpty {
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
        if participantsCount == maxParticipants {
            stringResource(.full)
        } else {
            stringResource(
                .participantNumber,
                participantsCount,
                maxParticipants
            )
        }
    }
}
