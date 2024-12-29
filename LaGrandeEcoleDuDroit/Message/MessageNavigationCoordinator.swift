import SwiftUI

class MessageNavigationCoordinator: NavigationCoordinator {
    @Published var paths: NavigationPath = NavigationPath()

    func push(_ screen: any Screen) {
        paths.append(screen)
    }
    
    func pop() {
        paths.removeLast()
    }
    
    func popToRoot() {
        paths.removeLast(paths.count)
    }
}
