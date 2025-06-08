struct CoreDataChange<T> {
    let inserted: [T]
    let updated: [T]
    let deleted: [T]
}
