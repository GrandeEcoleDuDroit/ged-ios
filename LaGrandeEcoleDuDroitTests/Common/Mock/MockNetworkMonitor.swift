import Combine

class MockNetworkMonitor: NetworkMonitor {
    var connected: AnyPublisher<Bool, Never> { Empty().eraseToAnyPublisher() }
    
    var isConnected: Bool { false }
}
