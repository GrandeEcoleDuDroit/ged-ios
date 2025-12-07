extension Array<User> {
    func missionManagerSorting() -> [User] {
        sorted { a, b in
            if a.admin != b.admin {
                return a.admin
            }
            
            return a.fullName < b.fullName
        }
    }
    
    func missionManagerSorting(mission: Mission) -> [User] {
        let managerIds = mission.managers.map { $0.id }.toSet()
        
        func priority(_ user: User) -> Int {
            switch user {
                case _ where managerIds.contains(user.id): 0
                case _ where user.admin: 1
                default: 2
            }
        }
        
        return sorted { a, b in
            let pa = priority(a)
            let pb = priority(b)

            if pa != pb {
                return pa < pb
            }

            return a.fullName < b.fullName
        }
    }
}
