import Foundation
import SwiftUI
import Combine

class NavigationCoordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    
    func push(_ screen: any Screen) {
        path.append(screen)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
