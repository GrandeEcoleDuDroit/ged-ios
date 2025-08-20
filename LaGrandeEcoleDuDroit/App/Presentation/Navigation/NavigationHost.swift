import SwiftUI

struct NavigationHost: View {
    @StateObject private var viewModel = MainInjection.shared.resolve(NavigationHostViewModel.self)
   
    var body: some View {
        ZStack {
            switch viewModel.uiState.startDestination {
                case .authentication: AuthenticationNavigation()
                case .app: AppNavigation().environmentObject(viewModel)
                case .splash: SplashScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
