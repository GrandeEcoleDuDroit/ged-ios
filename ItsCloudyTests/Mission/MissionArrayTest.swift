import Testing
import Foundation
import Combine

@testable import ItsCloudy

class MissionArrayTest {
    private let notPublisheddMission : [Mission] = [
        missionFixture.copy {
            $0.id = "9";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().plusDays(10);
            $0.date = Date().minusDay(20);
            $0.state = .error()
        },
        missionFixture.copy {
            $0.id = "10";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().minusDay(10);
            $0.date = Date().minusDay(20);
            $0.state = .publishing()
        },
        missionFixture.copy {
            $0.id = "11";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().minusDay(1);
            $0.date = Date().minusDay(30);
            $0.state = .publishing()
        }
    ]
    
    private let notCompletedMission : [Mission] = [
        missionFixture.copy {
            $0.id = "0";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().plusDays(10);
            $0.date = Date().minusDay(20)
        },
        missionFixture.copy {
            $0.id = "1";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().plusDays(10);
            $0.date = Date().minusDay(10)
        },
        missionFixture.copy {
            $0.id = "2";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().plusDays(1);
            $0.date = Date().minusDay(20)
        },
        missionFixture.copy {
            $0.id = "3";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().plusDays(1);
            $0.date = Date().minusDay(30)
        },
        missionFixture.copy {
            $0.id = "4";
            $0.startDate = Date().minusDay(20);
            $0.endDate = Date().plusDays(40);
            $0.date = Date().minusDay(30)
        },
        missionFixture.copy {
            $0.id = "5";
            $0.startDate = Date().minusDay(30);
            $0.endDate = Date().plusDays(40);
            $0.date = Date().minusDay(30)
        },
    ]
    
    private let completedMission : [Mission] = [
        missionFixture.copy {
            $0.id = "6";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().minusDay(1);
            $0.date = Date().minusDay(20);
        },
        missionFixture.copy {
            $0.id = "7";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().minusDay(10);
            $0.date = Date().minusDay(20)
        },
        missionFixture.copy {
            $0.id = "8";
            $0.startDate = Date().minusDay(10);
            $0.endDate = Date().minusDay(2);
            $0.date = Date().minusDay(30)
        }
    ]
    
    private let allMissions: [Mission]
    
    init() {
        allMissions = notCompletedMission + completedMission + notPublisheddMission
    }
    
    @Test
    func missionSorting_should_set_not_published_mission_first() async {
        // When
        let result = allMissions.missionSorting()

        // Then
        let firstThreeMissions = [result[0], result[1], result[2]]
        let intersection = Array(Set(notPublisheddMission).intersection(firstThreeMissions))
        let expectedResult = intersection.count == 3
        #expect(expectedResult)
    }
    
    @Test
    func missionSorting_should_set_not_completed_mission_second() async {
        // When
        let result = allMissions.missionSorting()
        
        // Then
        let secondFourMissions = [result[3], result[4], result[5], result[6], result[7], result[8]]
        let intersection = Array(Set(notCompletedMission).intersection(secondFourMissions))
        let expectedResult = intersection.count == 6
        #expect(expectedResult)
    }
    
    @Test
    func missionSorting_should_set_completed_mission_last() async {
        // When
        let result = allMissions.missionSorting()
        
        // Then
        let lastThreeMissions = [result[9], result[10], result[11]]
        let intersection = Array(Set(completedMission).intersection(lastThreeMissions))
        let expectedResult = intersection.count == 3
        #expect(expectedResult)
    }
    
    @Test
    func missionSorting_should_sort_not_published_mission_by_date_desc() async {
        // Given
        let missions = missionsFixture.map { mission in mission.copy { $0.state = .error() } }
        
        // When
        let result = missions.missionSorting()
        
        // Then
        let expectedResult = missions.sorted { $0.date > $1.date }
        #expect(result == expectedResult)
    }
    
    @Test
    func missionSorting_should_sort_not_completed_mission_by_start_date_first() async {
        // When
        let result = notCompletedMission.missionSorting()
        
        // Then
        let firstTwoMissions = [result[0], result[1]]
        let minStartDateNotCompletedMissions = [notCompletedMission[4], notCompletedMission[5]]
        let intersection = Array(Set(minStartDateNotCompletedMissions).intersection(firstTwoMissions))
        let expectedResult = intersection.count == 2
        #expect(expectedResult)
    }
    
    @Test
    func missionSorting_should_sort_not_completed_mission_by_end_date_second() async {
        // When
        let result = notCompletedMission.missionSorting()
        
        // Then
        let secondTwoMissions = [result[2], result[3]]
        let minEndDateNotCompletedMissions = [notCompletedMission[2], notCompletedMission[3]]
        let intersection = Array(Set(minEndDateNotCompletedMissions).intersection(secondTwoMissions))
        let expectedResult = intersection.count == 2
        #expect(expectedResult)
    }
    
    @Test
    func missionSorting_should_sort_not_completed_mission_by_date_desc_third() async {
        // When
        let result = notCompletedMission.missionSorting()
        
        // Then
        let lastTwoMissions = [result[4], result[5]]
        let maxDateNotCompletedMissions = [notCompletedMission[0], notCompletedMission[1]].sorted { $0.date > $1.date }
        let expectedResult = lastTwoMissions == maxDateNotCompletedMissions
        #expect(expectedResult)
    }
    
    @Test
    func missionSorting_should_sort_completed_mission_by_end_date_desc() async {
        // When
        let result = completedMission.missionSorting()
        
        // Then
        let expectedResult = result == completedMission.sorted { $0.endDate > $1.endDate }
        #expect(expectedResult)
    }
}
