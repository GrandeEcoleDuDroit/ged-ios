import Combine
import SwiftUI
import Foundation

struct AppNavigation: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(AppNavigationViewModel.self)
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(viewModel.uiState.topLevelDestinations) { tab in
                TabContent(
                    tab: tab,
                    selected: tab == viewModel.selectedTab,
                    badge: viewModel.uiState.badges[tab] ?? 0
                )
            }
        }
    }
}

private struct TabContent: View {
    let tab: TopLevelDestination
    let icon: String
    let badge: Int
    
    init(
        tab: TopLevelDestination,
        selected: Bool,
        badge: Int
    ) {
        self.tab = tab
        self.icon = selected ? tab.filledIcon : tab.outlinedIcon
        self.badge = badge
    }
    
    var body: some View {
        Group {
            switch tab {
                case .home: NewsNavigation()
                case .message: MessageNavigation().badge(badge)
                case .mission: MissionNavigation()
                case .profile: ProfileNavigation()
            }
        }
        .tabItem {
            Label(tab.label, systemImage: icon)
                .environment(\.symbolVariants, .none)
        }
        .tag(tab)
    }
}
