extension Array<Mission> {
    func missionSorting() -> [Mission] {
        func priority(_ mission: Mission) -> Int {
            switch mission {
                case _ where
                    !mission.completed ||
                    mission.state.type != Mission.MissionState.StateType.publishedType: 0
                default: 2
            }
        }
        
        return sorted { a, b in
            let pa = priority(a)
            let pb = priority(b)

            if pa != pb {
                return pa < pb
            }

            return a.date > b.date
        }
    }
}
