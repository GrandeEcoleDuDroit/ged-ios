import Foundation
import Testing
@testable import GrandeEcoleDuDroit

struct GetElapsedTimeUseCaseTests {

    @Test
    func should_return_now_when_duration_is_less_than_1_minute() {
        let date = Date().addingTimeInterval(-30) // 30 seconds ago

        let result = GetElapsedTimeUseCase.execute(date: date)

        #expect(result == .now(seconds: 30))
    }

    @Test
    func should_return_minutes_when_duration_is_less_than_1_hour() {
        let date = Date().addingTimeInterval(-60 * 30) // 30 minutes ago

        let result = GetElapsedTimeUseCase.execute(date: date)

        #expect(result == .minute(minutes: 30))
    }

    @Test
    func should_return_hours_when_duration_is_between_1_and_24_hours() {
        let date = Date().addingTimeInterval(-3600 * 5) // 5 hours ago

        let result = GetElapsedTimeUseCase.execute(date: date)

        #expect(result == .hour(hours: 5))
    }

    @Test
    func should_return_days_when_duration_is_between_1_and_7_days() {
        let date = Date().addingTimeInterval(-86400 * 2) // 2 days ago

        let result = GetElapsedTimeUseCase.execute(date: date)

        #expect(result == .day(days: 2))
    }

    @Test
    func should_return_weeks_when_duration_is_between_7_and_30_days() {
        let date = Date().addingTimeInterval(-86400 * 14) // 14 days ago

        let result = GetElapsedTimeUseCase.execute(date: date)

        #expect(result == .week(weeks: 2))
    }

    @Test
    func should_return_later_when_duration_is_more_than_30_days() {
        let date = Date().addingTimeInterval(-86400 * 60) // 60 days ago

        let result = GetElapsedTimeUseCase.execute(date: date)

        #expect(result == .later(date: date))
    }
}
