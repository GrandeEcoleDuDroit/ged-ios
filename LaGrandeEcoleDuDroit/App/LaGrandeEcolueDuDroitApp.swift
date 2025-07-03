import SwiftUI
import FirebaseCore
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        
        settings.cacheSettings = MemoryCacheSettings()
        db.clearPersistence()
        db.settings = settings
        return true
    }
}

@main
struct LaGrandeEcolueDuDroitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var mainViewModel: MainViewModel = MainInjection.shared.resolve(MainViewModel.self)

    var body: some Scene {
        WindowGroup {
            Navigation()
                .task {
                    await MessageInjection.shared.resolve(MessageTaskLauncher.self).launch()
                }
        }
    }
}
