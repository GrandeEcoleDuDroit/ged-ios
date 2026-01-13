import SwiftUI

@main
struct LaGrandeEcolueDuDroitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var mainViewModel: MainViewModel = AppInjector.shared.resolve(MainViewModel.self)

    var body: some Scene {
        WindowGroup {
            NavigationHost()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
    }
}
