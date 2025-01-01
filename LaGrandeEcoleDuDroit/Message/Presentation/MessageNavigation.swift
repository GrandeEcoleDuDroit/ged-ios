import SwiftUI

struct MessageNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var messageNavigationCoordinator = NavigationCoordinator()
    @StateObject private var conversationViewModel = DependencyContainer.shared.conversationViewModel
    @StateObject private var createConversationViewModel = DependencyContainer.shared.createConversationViewModel
    
    var body: some View {
        NavigationStack(path: $messageNavigationCoordinator.path) {
            ConversationView()
                .environmentObject(conversationViewModel)
                .navigationDestination(for: MessageScreen.self) { screen in
                    switch screen {
                        case .chat(let conversation):
                            ChatView(conversation: conversation)
                                .environmentObject(
                                    ChatViewModel(
                                        getMessagesUseCase: DependencyContainer.shared.getMessagesUseCase,
                                        getCurrentUserUseCase: DependencyContainer.shared.getCurrentUserUseCase,
                                        generateIdUseCase: DependencyContainer.shared.generateIdUseCase,
                                        createConversationUseCase: DependencyContainer.shared.createConversationUseCase,
                                        conversation: conversation
                                    )
                                )
                        case .createConversation:
                            CreateConversationView()
                                .environmentObject(DependencyContainer.shared.createConversationViewModel)
                    }
                }
        }
        .environmentObject(messageNavigationCoordinator)
        .environmentObject(tabBarVisibility)
    }
}

#Preview {
    struct ConversationView_Previews: View {
        @StateObject var navigationCoordinator = NavigationCoordinator()
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ConversationView()
                    .environmentObject(DependencyContainer.shared.mockConversationViewModel)
                    .navigationDestination(for: MessageScreen.self) { screen in
                        switch screen {
                            case .chat(let conversation):
                                ChatView(conversation: conversation)
                                    .environmentObject(
                                        ChatViewModel(
                                            getMessagesUseCase: DependencyContainer.shared.getMessagesUseCase,
                                            getCurrentUserUseCase: DependencyContainer.shared.getCurrentUserUseCase,
                                            generateIdUseCase: DependencyContainer.shared.generateIdUseCase,
                                            createConversationUseCase: DependencyContainer.shared.createConversationUseCase,
                                            conversation: conversation
                                        )
                                    )
                            case .createConversation:
                                CreateConversationView()
                                    .environmentObject(DependencyContainer.shared.mockCreateConversationViewModel)
                        }
                    }
            }
            .environmentObject(TabBarVisibility())
            .environmentObject(navigationCoordinator)
        }
    }
    
    return ConversationView_Previews()
}
