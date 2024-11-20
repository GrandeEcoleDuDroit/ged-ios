import CoreData

private let containerName = "GedoiseDatabase"

open class GedDatabaseContainer {
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error {
                print("Failed to load local datas: \(error)")
            }
        }
    }
}


