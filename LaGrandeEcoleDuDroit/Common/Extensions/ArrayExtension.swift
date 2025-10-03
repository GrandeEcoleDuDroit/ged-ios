extension Array {
    func toSet() -> Set<Element> where Element: Hashable {
        Set(self)
    }
}
