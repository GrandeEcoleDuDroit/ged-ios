import SwiftUI

struct MessageNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var messageNavigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
    @StateObject private var conversationViewModel = MessageDependencyInjectionContainer.shared.resolve(ConversationViewModel.self)
    @StateObject private var createConversationViewModel = MessageDependencyInjectionContainer.shared.resolve(CreateConversationViewModel.self)
    
    var body: some View {
        NavigationStack(path: $messageNavigationCoordinator.path) {
            ConversationView()
                .environmentObject(conversationViewModel)
                .navigationDestination(for: MessageScreen.self) { screen in
                    switch screen {
                        case .chat(let conversation):
                            ChatView(conversation: conversation)
                                .environmentObject(
                                    MessageDependencyInjectionContainer.shared.resolve(ChatViewModel.self, arguments: conversation)!
                                )
                        case .createConversation:
                            CreateConversationView()
                                .environmentObject(createConversationViewModel)
                    }
                }
        }
        .environmentObject(messageNavigationCoordinator)
        .environmentObject(tabBarVisibility)
    }
}

#Preview {
    struct MessageNavigation_Preview: View {
        @StateObject var navigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
        let mockConversationViewModel = MessageDependencyInjectionContainer.shared.resolveWithMock().resolve(ConversationViewModel.self)!
        let mockCreateConversationViewModel = MessageDependencyInjectionContainer.shared.resolveWithMock().resolve(CreateConversationViewModel.self)!
        let tabBarVisibility = CommonDependencyInjectionContainer.shared.resolve(TabBarVisibility.self)
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ConversationView()
                    .environmentObject(mockConversationViewModel)
                    .navigationDestination(for: MessageScreen.self) { screen in
                        switch screen {
                        case .chat(let conversation):
                            ChatView(conversation: conversation)
                                .environmentObject(
                                    MessageDependencyInjectionContainer.shared.resolveWithMock().resolve(ChatViewModel.self, argument: conversation)!
                                )
                        case .createConversation:
                            CreateConversationView()
                                .environmentObject(mockCreateConversationViewModel)
                        }
                    }
            }
            .environmentObject(tabBarVisibility)
            .environmentObject(navigationCoordinator)
        }
    }
    
    return MessageNavigation_Preview()
}
