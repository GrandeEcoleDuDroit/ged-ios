import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
//        Auth.auth().useEmulator(withHost:"127.0.0.1", port:9099)
        
        return true
    }
}

@main
struct LaGrandeEcolueDuDroitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @StateObject private var registrationViewModel = RegistrationViewModel()
    @StateObject private var newsViewModel = NewsViewModel()
    @State private var isAuthenticated: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HStack {
                    if isAuthenticated {
                        NewsView()
                            .environmentObject(newsViewModel)
                    } else {
                        AuthenticationView()
                            .environmentObject(authenticationViewModel)
                            .environmentObject(registrationViewModel)
                    }
                }
                .onReceive(authenticationViewModel.$authenticationState) { state in
                    if state == .authenticated {
                        isAuthenticated = true
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
}
