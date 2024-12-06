import Foundation
import Combine
import CoreData

private let conversationEntityName = "LocalConversation"

class ConversationLocalRepositoryImpl: ConversationLocalRepository {
    private let gedDatabaseContainer: GedDatabaseContainer
    private let request = NSFetchRequest<LocalConversation>(entityName: conversationEntityName)
    private let context: NSManagedObjectContext
    
    @Published private var _conversations: [Conversation] = []
    var conversations: AnyPublisher<[Conversation], Never> {
        $_conversations.eraseToAnyPublisher()
    }
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        self.gedDatabaseContainer = gedDatabaseContainer
        context = gedDatabaseContainer.container.viewContext
        fetchConversations()
    }
    
    private func fetchConversations() {
        do {
            _conversations = try context.fetch(request).compactMap({ localConversation in
                ConversationMapper.toDomain(localConversation: localConversation)
            })
        } catch {
            print("Failed to fetch conversations: \(error)")

        }
    }
}
