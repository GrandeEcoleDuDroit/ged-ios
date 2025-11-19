import Foundation

class MissionFormatter {
    private init() {}
    
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
}
