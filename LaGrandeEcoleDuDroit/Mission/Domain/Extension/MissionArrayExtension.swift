import Foundation

extension Array<Mission> {
    func missionSorting() -> [Mission] {
        func priority(_ mission: Mission) -> Int {
            switch mission {
                case _ where mission.state.type != Mission.MissionState.StateType.publishedType: 0
                case _ where !mission.completed: 1
                default: 2
            }
        }
        
        return sorted { lhs, rhs in
            let pa = priority(lhs)
            let pb = priority(rhs)

            if pa != pb {
                return pa < pb
            }

            return switch pa {
                case 0: lhs.date < rhs.date
                case 1: abs(lhs.startDate.timeIntervalSinceNow) <= abs(rhs.startDate.timeIntervalSinceNow)
                case 2: lhs.endDate > rhs.endDate
                default: lhs.date < rhs.date
            }
        }
    }
}
