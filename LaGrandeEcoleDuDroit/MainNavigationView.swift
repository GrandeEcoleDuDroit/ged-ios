import SwiftUI

struct MainNavigationView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                NewsView()
                    .environmentObject(newsViewModel)
            }
            .tabItem {
                let icon = selectedTab == 0 ? "house.fill" : "house"
                Label(getString(gedString: GedString.home), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(0)
            
            NavigationView {
                ConversationView()
                    .environmentObject(conversationViewModel)
            }
            .tabItem {
                let icon = selectedTab == 1 ? "message.fill" : "message"
                Label(getString(gedString: GedString.messages), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(1)
            
            NavigationView {
                ProfileView()
                    .environmentObject(profileViewModel)
            }
            .tabItem {
                let icon = selectedTab == 2 ? "person.fill" : "person"
                Label(getString(gedString: GedString.profile), systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .tag(2)
        }
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(DependencyContainer.shared.newsViewModel)
        .environmentObject(DependencyContainer.shared.conversationViewModel)
        .environmentObject(DependencyContainer.shared.profileViewModel)
}
