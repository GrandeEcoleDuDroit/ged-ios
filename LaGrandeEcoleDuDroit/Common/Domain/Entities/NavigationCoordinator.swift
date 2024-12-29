import Foundation
import SwiftUI
import Combine

protocol NavigationCoordinator: ObservableObject {
    var paths: NavigationPath { get set }
    
    func push(_ screen: any Screen)

    func pop()

    func popToRoot()
}
