import CoreData

private let containerName = "GedDatabase"

open class GedDatabaseContainer {
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load local data: \(error.localizedDescription)")
            }
        }
    }
}
