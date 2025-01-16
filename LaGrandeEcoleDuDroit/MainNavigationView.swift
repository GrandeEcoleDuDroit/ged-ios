import SwiftUI

struct MainNavigationView: View {
    private let isAuthenticatedUseCase: IsAuthenticatedUseCase = AuthenticationInjection.shared.resolve(IsAuthenticatedUseCase.self)
    @State private var authenticationState: AuthenticationState = .idle
    
    var body: some View {
        ZStack {
            switch authenticationState {
                case.idle:
                    SplashScreen()
                case .authenticated:
                    Main()
                default:
                    AuthenticationNavigation()
            }
        }
        .onReceive(isAuthenticatedUseCase.execute()) { value in
            authenticationState = value ? .authenticated : .unauthenticated
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
