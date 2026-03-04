struct CoreDataChange<T> {
    let inserted: [T]
    let updated: [T]
    let deleted: [T]
    
    init(
        inserted: [T] = [],
        updated: [T] = [],
        deleted: [T] = []
    ) {
        self.inserted = inserted
        self.updated = updated
        self.deleted = deleted
    }
}

enum Change {
    case inserted
    case updated
    case deleted
}

