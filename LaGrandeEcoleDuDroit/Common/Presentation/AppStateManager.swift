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
    case registering
    case loggingInOut
    
    var loading: Bool {
        switch self {
            case .loggingInOut, .registering: true
            default: false
        }
    }
}
