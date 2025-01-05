import SwiftUI

struct MainNavigationView: View {
    @StateObject private var authenticationViewModel = AuthenticationDependencyInjectionContainer.shared.resolve(AuthenticationViewModel.self)
    @StateObject private var registrationViewModel = AuthenticationDependencyInjectionContainer.shared.resolve(RegistrationViewModel.self)
    @State private var authenticationState: AuthenticationState = .idle
    
    var body: some View {
        ZStack {
            switch authenticationState {
            case.idle:
                SplashScreen()
            case .authenticated:
                Main()
            default:
                Authentication()
                    .environmentObject(authenticationViewModel)
                    .environmentObject(registrationViewModel)
            }
        }
        .onReceive(authenticationViewModel.$authenticationState) { state in
            authenticationState = state
        }
        .onReceive(registrationViewModel.$registrationState) { state in
            if state == .emailVerified {
                authenticationState = .authenticated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct Authentication: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    
    var body: some View {
        AuthenticationNavigation()
            .environmentObject(authenticationViewModel)
            .environmentObject(registrationViewModel)
    }
}

private enum Tabs {
    case news, conversation, profile
}
 
struct Main: View {
    @StateObject private var tabBarVisibility = CommonDependencyInjectionContainer.shared.resolve(TabBarVisibility.self)
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
