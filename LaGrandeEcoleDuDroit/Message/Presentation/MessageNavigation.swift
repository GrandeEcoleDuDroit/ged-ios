import SwiftUI

struct MessageNavigation: View {
    @StateObject private var messageNavigationCoordinator = NavigationCoordinator()
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    
    var body: some View {
        NavigationStack(path: $messageNavigationCoordinator.path) {
            ConversationView()
                .navigationDestination(for: MessageScreen.self) { screen in
                    switch screen {
                        case .chat(let conversation):
                            ChatView(conversation: conversation)
                        case .createConversation:
                            CreateConversationView()
                    }
                }
        }
        .environmentObject(messageNavigationCoordinator)
        .environmentObject(tabBarVisibility)
    }
}

#Preview {
    struct MessageNavigation_Preview: View {
        @StateObject var navigationCoordinator = NavigationCoordinator()
        @StateObject var tabBarVisibility = TabBarVisibility()
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ConversationView()
                    .navigationDestination(for: MessageScreen.self) { screen in
                        switch screen {
                        case .chat(let conversation):
                            ChatView(conversation: conversation)
                        case .createConversation:
                            CreateConversationView()
                        }
                    }
            }
            .environmentObject(tabBarVisibility)
            .environmentObject(navigationCoordinator)
        }
    }
    
    return MessageNavigation_Preview()
}
