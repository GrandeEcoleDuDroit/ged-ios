import Foundation
import Combine
import CoreData
import os

private let messageEntityName = "LocalMessage"
private let logger = Logger(subsystem: "com.upsaclay.gedoise", category: "MessageLocalDataSource")

class MessageLocalDataSource {
    private let gedDatabaseContainer: GedDatabaseContainer
    private let request = NSFetchRequest<LocalMessage>(entityName: messageEntityName)
    private let context: NSManagedObjectContext
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        self.gedDatabaseContainer = gedDatabaseContainer
        context = gedDatabaseContainer.container.viewContext
    }
    
    func getMessages(conversationId: String, offeset: Int, limit: Int) async throws -> [LocalMessage] {
        request.predicate = NSPredicate(format: "conversationId == %@", conversationId)
        request.fetchLimit = limit
        request.fetchOffset = offeset
        return try context.fetch(request)
    }
}
