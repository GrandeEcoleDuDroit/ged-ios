protocol Copying {}

extension Copying {
    func copy(_ mutating: (inout Self) -> Void) -> Self {
        var copy = self
        mutating(&copy)
        return copy
    }
}
