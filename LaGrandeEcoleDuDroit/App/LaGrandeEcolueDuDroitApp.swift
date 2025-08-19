import SwiftUI

@main
struct LaGrandeEcolueDuDroitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var mainViewModel: MainViewModel = MainInjection.shared.resolve(MainViewModel.self)

    var body: some Scene {
        WindowGroup {
            NavigationHost()
        }
    }
}
