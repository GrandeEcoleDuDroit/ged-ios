import Combine
import SwiftUI
import Foundation

struct AppNavigation: View {
    @StateObject private var viewModel: AppNavigationViewModel = MainInjection.shared.resolve(AppNavigationViewModel.self)
    @State var selectedTab: TopLevelDestination = .home
    @StateObject private var tabBarVisibility = TabBarVisibility()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TopLevelDestination.allCases, id: \.self) { tab in
                tabView(tab)
            }
        }
        .onReceive(viewModel.$tabToNavigate) { destinationToNavigate in
            if let destination = destinationToNavigate {
                selectedTab = destination
            }
        }
    }

    @ViewBuilder
    private func tabView(_ tab: TopLevelDestination) -> some View {
        let icon = selectedTab == tab ? tab.filledIcon : tab.outlinedIcon
        let badgeCount = viewModel.uiState.badges[tab] ?? 0

        destinationView(for: tab)
            .environmentObject(tabBarVisibility)
            .tabItem {
                Label(tab.label, systemImage: icon)
                    .environment(\.symbolVariants, .none)
            }
            .badge(badgeCount)
            .tag(tab)
            .toolbar(tabBarVisibility.show ? .visible : .hidden, for: .tabBar)
    }

    @ViewBuilder
    private func destinationView(for tab: TopLevelDestination) -> some View {
        switch tab {
            case .home: NewsNavigation()
            case .message: MessageNavigation()
            case .profile: ProfileNavigation()
        }
    }
}

class TabBarVisibility: ObservableObject {
    @Published var show: Bool = false
}
