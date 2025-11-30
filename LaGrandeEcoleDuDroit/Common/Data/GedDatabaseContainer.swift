import CoreData

open class GedDatabaseContainer {
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GedDatabase")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        } else {
            container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
            container.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
        }
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load core data: \(error.localizedDescription)")
            }
        }
    }
}

extension GedDatabaseContainer {
    static let preview: GedDatabaseContainer = {
        let container = GedDatabaseContainer(inMemory: true)
        return container
    }()
}
