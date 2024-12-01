import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
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
    @StateObject private var profileViewModel = DependencyContainer.shared.profileViewModel
    @State private var isAuthenticated: Bool = false

    var body: some Scene {
        WindowGroup {
            HStack {
                if isAuthenticated {
                    MainNavigationView()
                        .environmentObject(newsViewModel)
                        .environmentObject(profileViewModel)
                } else {
                    AuthenticationView()
                        .environmentObject(authenticationViewModel)
                        .environmentObject(registrationViewModel)
                }
            }
            .onReceive(authenticationViewModel.$authenticationState) { state in
                if state == .authenticated {
                    isAuthenticated = true
                } else if state == .unauthenticated {
                    isAuthenticated = false
                }
            }
            .onReceive(registrationViewModel.$registrationState) { state in
                if state == .emailVerified {
                    isAuthenticated = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
