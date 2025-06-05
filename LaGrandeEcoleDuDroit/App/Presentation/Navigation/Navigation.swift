import Combine
import SwiftUI
import Foundation

struct Navigation: View {
    @StateObject private var viewModel: NavigationViewModel = MainInjection.shared.resolve(NavigationViewModel.self)
   
    var body: some View {
        ZStack {
            switch viewModel.uiState.startDestination {
                case .authentication: AuthenticationNavigation()
                case .home: MainNavigation(topLevelDestinations: viewModel.uiState.topLevelDestinations)
                case .splash: SplashScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct MainNavigation: View {
    let topLevelDestinations: [TopLevelDestination]
    @State private var currentTopLevelDestination: TopLevelDestination = .home
    @StateObject private var tabBarVisibility = TabBarVisibility()

    var body: some View {
        TabView(selection: $currentTopLevelDestination) {
            ForEach(topLevelDestinations, id: \.self) { destination in
                ChooseDestination(destination: destination)
                    .environmentObject(tabBarVisibility)
                    .tabItem {
                        let icon = currentTopLevelDestination == destination ? destination.filledIcon : destination.outlinedIcon
                        Label(destination.label, systemImage: icon)
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(destination)
                    .toolbar(tabBarVisibility.show ? .visible : .hidden, for: .tabBar)
            }
        }
    }
}

private struct ChooseDestination: View {
    let destination: TopLevelDestination

    var body: some View {
        switch destination {
            case .home: NewsNavigation()
            case let .message(badges): MessageNavigation().badge(badges)
            case .profile: ProfileNavigation()
        }
    }
}

class TabBarVisibility: ObservableObject {
    @Published var show: Bool = false
}

#Preview {
    MainNavigation(topLevelDestinations: [.home, .message(badges: 3), .profile])
}
