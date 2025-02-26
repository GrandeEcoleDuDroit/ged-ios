import SwiftUI

struct MainNavigationView: View {
    @StateObject private var mainViewModel: MainViewModel = MainInjection.shared.resolve(MainViewModel.self)
    
    var body: some View {
        ZStack {
            switch mainViewModel.authenticationState {
                case .waiting:
                    SplashScreen()
                case .authenticated:
                    Main()
                default:
                    AuthenticationView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private enum Tabs {
    case news, conversation, profile
}

struct Main: View {
    @StateObject private var tabBarVisibility = TabBarVisibility()
    @State private var selectedTab: Tabs = .news
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NewsNavigation()
                .environmentObject(tabBarVisibility)
                .tabItem {
                    let icon = selectedTab == .news ? "house.fill" : "house"
                    Label(getString(.home), systemImage: icon)
                        .environment(\.symbolVariants, .none)
                }
                .tag(Tabs.news)
                .toolbar(tabBarVisibility.show ? .visible : .hidden, for: .tabBar)
            
            MessageNavigation()
                .environmentObject(tabBarVisibility)
                .tabItem {
                    let icon = selectedTab == .conversation ? "message.fill" : "message"
                    Label(getString(.messages), systemImage: icon)
                        .environment(\.symbolVariants, .none)
                }
                .tag(Tabs.conversation)
                .toolbar(tabBarVisibility.show ? .visible : .hidden, for: .tabBar)
            
            ProfileNavigation()
                .environmentObject(tabBarVisibility)
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
    Main()
}
