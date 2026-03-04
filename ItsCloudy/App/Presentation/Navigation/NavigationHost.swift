import SwiftUI

struct NavigationHost: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(NavigationHostViewModel.self)
   
    var body: some View {
        ZStack {
            switch viewModel.uiState.startDestination {
                case .authentication: AuthenticationNavigation()
                case .app: AppNavigation()
                case .splash: SplashScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
