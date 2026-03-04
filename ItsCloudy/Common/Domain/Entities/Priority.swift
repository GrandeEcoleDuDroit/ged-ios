enum Priority: Int {
    case first = 1
    case second = 2
    case third = 3
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
