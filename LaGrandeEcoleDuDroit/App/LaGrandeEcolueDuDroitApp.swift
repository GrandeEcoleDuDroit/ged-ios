import SwiftUI

@main
struct LaGrandeEcolueDuDroitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var mainViewModel: MainViewModel = AppInjector.shared.resolve(MainViewModel.self)

    var body: some Scene {
        WindowGroup {
            NavigationHost()
        }
    }
}
