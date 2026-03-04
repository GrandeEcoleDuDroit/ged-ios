protocol Withable {}

extension Withable {
    func with(_ changes: (inout Self) -> Void) -> Self {
        var copy = self
        changes(&copy)
        return copy
    }
}
