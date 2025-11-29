import ObjectiveC

extension Optional where Wrapped: Any {
    func takeIf(_ predicate: (Wrapped) -> Bool) -> Wrapped? {
        guard let value = self else { return nil }
        return predicate(value) ? value : nil
    }
}

extension Comparable {
    func takeIf(_ predicate: (Self) -> Bool) -> Self? {
        predicate(self) ? self : nil
    }
}

extension NSObject {
    func takeIf(_ predicate: (Self) -> Bool) -> Self? {
        predicate(self) ? self : nil
    }
}
