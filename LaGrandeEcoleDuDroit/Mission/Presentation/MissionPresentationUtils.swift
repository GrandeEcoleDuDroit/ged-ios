import Foundation
import SwiftUI

struct MissionPresentationUtils {
    private init() {}
    
    static let maxTitleLength: Int = 100
    static let maxDescriptionLength: Int = 1000
    static let maxDurationLength: Int = 200
    static let maxTaskLength: Int = 300
    
    static let titleFont: Font = .title
    static let descriptionFont: Font = .body
    static let contentFont: Font = .callout
    
    static func formatSchoolLevels(schoolLevels: [SchoolLevel]) -> String {
        schoolLevels.sorted { $0.number < $1.number }
            .map { $0.rawValue }
            .joined(separator: " - ")
    }
    
    static func formatDate(startDate: Date, endDate: Date) -> String {
        if startDate == endDate {
            startDate.formatDayMonthYear()
        } else {
            startDate.formatDayMonthYear() + " - " + endDate.formatDayMonthYear()
        }
    }
    
    static func formatRemainingParticipants(participantsCout: Int, maxParticipants: Int) -> String {
        let remainingParticipants = max(maxParticipants - participantsCout, 0)
        return remainingParticipants.takeIf { $0 < 100 }?.description ?? "99+"
    }
}
