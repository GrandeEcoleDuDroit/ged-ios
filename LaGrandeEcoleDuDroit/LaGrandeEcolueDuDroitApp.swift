import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct LaGrandeEcolueDuDroitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authenticationViewModel = DependencyContainer.shared.authenticationViewModel
    @StateObject private var registrationViewModel = DependencyContainer.shared.registrationViewModel
    @StateObject private var newsViewModel = DependencyContainer.shared.newsViewModel
    @StateObject private var conversationViewModel = DependencyContainer.shared.conversationViewModel
    @StateObject private var profileViewModel = DependencyContainer.shared.profileViewModel
    @State private var authenticationState: AuthenticationState = .idle

    var body: some Scene {
        WindowGroup {
            HStack {
                switch authenticationState {
                    case .authenticated:
                        MainNavigationView()
                            .environmentObject(newsViewModel)
                            .environmentObject(conversationViewModel)
                            .environmentObject(profileViewModel)
                    case .unauthenticated:
                        AuthenticationView()
                            .environmentObject(authenticationViewModel)
                            .environmentObject(registrationViewModel)
                    default:
                        SplashScreen()
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
}
