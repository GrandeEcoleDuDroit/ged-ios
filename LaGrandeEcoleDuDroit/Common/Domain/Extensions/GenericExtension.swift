extension Equatable {
    func takeIf(_ predicate: (Self) -> Bool) -> Self? {
        predicate(self) ? self : nil
    }
    
    func takeUnless(_ predicate: (Self) -> Bool) -> Self? {
        !predicate(self) ? self : nil
    }
    
    func letBlock<R>(_ action: (Self) -> R) -> R {
        action(self)
    }
}
