struct CoreDataChange<T> {
    let inserted: [T]
    let updated: [T]
    let deleted: [T]
}

enum Change {
    case inserted
    case updated
    case deleted
}

