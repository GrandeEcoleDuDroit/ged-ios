import SwiftUI

struct MessageNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var path: [MessageRoute] = []
    private let routeRepository = CommonInjection.shared.resolve(RouteRepository.self)
    
    var body: some View {
        NavigationStack(path: $path) {
            ConversationDestination(
                onCreateConversationClick: { path.append(.createConversation) },
                onConversationClick: { conversation in
                    path.append(.chat(conversation: conversation.toConversation()))
                }
            )
            .navigationModifier(route: MessageMainRoute.conversation, showTabBar: true)
            .background(Color.background)
            .navigationDestination(for: MessageRoute.self) { route in
                switch route {
                    case .chat(let conversation):
                        ChatDestination(
                            conversation: conversation,
                            onBackClick: { path.removeAll() }
                        )
                        .navigationModifier(route: route, showTabBar: false)
                        .background(Color.background)
                        
                    case .createConversation:
                        CreateConversationDestination(
                            onCreateConversationClick: { conversation in
                                path.append(.chat(conversation: conversation)) 
                            }
                        )
                        .navigationModifier(route: route, showTabBar: false)
                        .background(Color.background)
                        
                    default: EmptyView()
                }
            }
        }
    }
}

enum MessageRoute: Route {
    case conversation
    case chat(conversation: Conversation)
    case createConversation
}

private enum MessageMainRoute: Route {
    case conversation
}
