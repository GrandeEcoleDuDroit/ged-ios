import SwiftUI

private enum Tabs {
    case news, conversation, profile
}

struct MainNavigationView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var selectedTab: Tabs = .news
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                NewsView()
                    .environmentObject(newsViewModel)
            }
            .tabItem {
                let icon = selectedTab == .news ? "house.fill" : "house"
                Label(getString(.home), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tabs.news)
            
            NavigationView {
                ConversationView()
                    .environmentObject(conversationViewModel)
            }
            .tabItem {
                let icon = selectedTab == .conversation ? "message.fill" : "message"
                Label(getString(.messages), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tabs.conversation)
            
            NavigationView {
                ProfileView()
                    .environmentObject(profileViewModel)
            }
            .tabItem {
                let icon = selectedTab == .profile ? "person.fill" : "person"
                Label(getString(.profile), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tabs.profile)
        }
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(DependencyContainer.shared.mockNewsViewModel)
        .environmentObject(DependencyContainer.shared.mockConversationViewModel)
        .environmentObject(DependencyContainer.shared.profileViewModel)
}
