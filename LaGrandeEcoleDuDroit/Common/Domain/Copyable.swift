protocol Copyable {}

extension Copyable {
    func copy(_ mutating: (inout Self) -> Void) -> Self {
        var copy = self
        mutating(&copy)
        return copy
    }
}
