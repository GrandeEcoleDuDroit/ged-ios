extension Array {
    func toSet() -> Set<Element> where Element: Hashable {
        Set(self)
    }
    
    func replace(where predicate: (Element) -> Bool, with newValue: Element) -> [Element] {
        self.map { predicate($0) ? newValue : $0 }
    }
}

extension Array<User> {
    func managerSorting() -> [User] {
        self.sorted { $0.fullName < $1.fullName }
            .sorted { $0.admin == true && $1.admin == false }
    }
}
