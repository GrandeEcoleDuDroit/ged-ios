import SwiftUI

struct MessageNavigation: View {
    @StateObject private var viewModel = MessageMainThreadInjector.shared.resolve(MessageNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State var path: [MessageRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ConversationDestination(
                onCreateConversationClick: { path.append(.createConversation) },
                onConversationClick: { conversation in
                    path.append(.chat(conversation: conversation.toConversation()))
                }
            )
            .onAppear {
                tabBarVisibility.show = true
                viewModel.setCurrentRoute(MessageMainRoute.conversation)
            }
            .background(Color.background)
            .navigationDestination(for: MessageRoute.self) { route in
                switch route {
                    case .chat(let conversation):
                        ChatDestination(
                            conversation: conversation,
                            onBackClick: { path.removeAll() },
                            onInterlocutorClick: { user in
                                path.append(.interlocutor(user: user))
                            }
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(Color.background)
                        
                    case .createConversation:
                        CreateConversationDestination(
                            onCreateConversationClick: { conversation in
                                path.append(.chat(conversation: conversation)) 
                            }
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(Color.background)
                        
                    case .interlocutor(let user):
                        UserDestination(user: user)
                            .onAppear {
                                tabBarVisibility.show = false
                                viewModel.setCurrentRoute(route)
                            }
                            .background(Color.background)
                }
            }
            .onReceive(viewModel.$routeToNavigate) { routeToNavigate in
                guard let messageRoutes =
                        routeToNavigate?.routes.compactMap({ $0 as? MessageRoute }),
                        !messageRoutes.isEmpty
                else {
                    return
                }
                
                path = messageRoutes
            }
        }
    }
}

enum MessageRoute: Route {
    case chat(conversation: Conversation)
    case createConversation
    case interlocutor(user: User)
}

enum MessageMainRoute: MainRoute {
    case conversation
}
