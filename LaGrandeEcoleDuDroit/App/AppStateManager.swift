import Combine

class AppStateManager: ObservableObject {
    @Published private(set) var state: AppState = .defaultState
    
    func updateState(_ state: AppState) {
        self.state = state
    }
    
    func resetState() {
        self.state = .defaultState
    }
}

enum AppState {
    case defaultState
    case logginOut
    
    var loading: Bool {
        switch self {
            case .logginOut: true
            default: false
        }
    }
}
