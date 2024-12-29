import SwiftUI

private enum Tabs {
    case news, conversation, profile
}

struct MainNavigationView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var tabBarVisibility = TabBarVisibility()
    @StateObject private var messageNavigationCoordinator = MessageNavigationCoordinator()
    @State private var selectedTab: Tabs = .news
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                NewsView()
                    .environmentObject(newsViewModel)
                    .environmentObject(tabBarVisibility)
            }
            .tabItem {
                let icon = selectedTab == .news ? "house.fill" : "house"
                Label(getString(.home), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tabs.news)
            .toolbar(tabBarVisibility.show ? .visible : .hidden, for: .tabBar)
            
            NavigationStack(path: $messageNavigationCoordinator.paths) {
                ConversationView()
                    .environmentObject(conversationViewModel)
                    .environmentObject(tabBarVisibility)
                    .environmentObject(messageNavigationCoordinator)
            }
            .tabItem {
                let icon = selectedTab == .conversation ? "message.fill" : "message"
                Label(getString(.messages), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tabs.conversation)
            .toolbar(tabBarVisibility.show ? .visible : .hidden, for: .tabBar)
            
            NavigationStack {
                ProfileView()
                    .environmentObject(profileViewModel)
            }
            .tabItem {
                let icon = selectedTab == .profile ? "person.fill" : "person"
                Label(getString(.profile), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tabs.profile)
            .toolbar(tabBarVisibility.show ? .visible : .hidden, for: .tabBar)
        }
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(DependencyContainer.shared.mockNewsViewModel)
        .environmentObject(DependencyContainer.shared.mockConversationViewModel)
        .environmentObject(DependencyContainer.shared.profileViewModel)
}
