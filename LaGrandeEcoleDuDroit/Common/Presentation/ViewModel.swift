import Combine

@MainActor
protocol ViewModel: ObservableObject {}

@MainActor
protocol NavigationViewModel: ViewModel {
    func setCurrentRoute(_ route: any Route)
}
