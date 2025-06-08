import Combine
import SwiftUI
import Foundation

struct Navigation: View {
    @StateObject private var viewModel: NavigationViewModel = MainInjection.shared.resolve(NavigationViewModel.self)
   
    var body: some View {
        ZStack {
            switch viewModel.uiState.startDestination {
                case .authentication: AuthenticationNavigation()
                case .home: MainNavigation(
                    topLevelDestinations: viewModel.uiState.topLevelDestinations,
                    selectedTopLevelDestination: $viewModel.uiState.selectedDestination
                )
                case .splash: SplashScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct MainNavigation: View {
    let topLevelDestinations: [TopLevelDestination]
    @Binding var selectedTopLevelDestination: TopLevelDestination
    @StateObject private var tabBarVisibility = TabBarVisibility()

    var body: some View {
        TabView(selection: $selectedTopLevelDestination) {
            ForEach(topLevelDestinations, id: \.self) { destination in
                Destination(destination: destination)
                    .environmentObject(tabBarVisibility)
                    .tabItem {
                        let icon = selectedTopLevelDestination == destination ? destination.filledIcon : destination.outlinedIcon
                        Label(destination.label, systemImage: icon)
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(destination)
                    .toolbar(tabBarVisibility.show ? .visible : .hidden, for: .tabBar)
            }
        }
    }
}

private struct Destination: View {
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
    MainNavigation(
        topLevelDestinations: [.home, .message(badges: 3), .profile],
        selectedTopLevelDestination: .constant(.home)
    )
}
