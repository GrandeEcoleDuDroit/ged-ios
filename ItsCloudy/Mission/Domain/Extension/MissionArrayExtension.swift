import Foundation

extension Array<Mission> {
    func missionSorting() -> [Mission] {
        func priority(_ mission: Mission) -> Priority {
            switch mission {
                case _ where mission.state.type != Mission.MissionState.StateType.publishedType: .first
                case _ where !mission.completed: .second
                default: .third
            }
        }
        
        return sorted { lhs, rhs in
            let pl = priority(lhs)
            let pr = priority(rhs)

            if pl != pr {
                return pl < pr
            }

            return switch pl {
                case .first: lhs.date > rhs.date
                case .second: lhs.date > rhs.date
                case .third: lhs.endDate > rhs.endDate
            }
        }
    }
}
