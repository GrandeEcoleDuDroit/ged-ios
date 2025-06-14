import SwiftUI

struct MessageNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var path: [MessageRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ConversationDestination(
                onCreateConversationClick: { path.append(.createConversation) },
                onConversationClick: { conversation in
                    path.append(.chat(conversation: conversation.toConversation()))
                }
            )
            .onAppear { tabBarVisibility.show = true }
            .background(Color.background)
            .navigationDestination(for: MessageRoute.self) { route in
                switch route {
                    case .chat(let conversation):
                        ChatDestination(
                            conversation: conversation,
                            onBackClick: { path.removeAll() }
                        )
                        .onAppear { tabBarVisibility.show = false }
                        .background(Color.background)
                        
                    case .createConversation:
                        CreateConversationDestination(
                            onCreateConversationClick: { conversation in
                                path.append(.chat(conversation: conversation)) 
                            }
                        )
                        .onAppear { tabBarVisibility.show = false }
                        .background(Color.background)
                }
            }
        }
    }
}

private enum MessageRoute: Hashable {
    case chat(conversation: Conversation)
    case createConversation
}
