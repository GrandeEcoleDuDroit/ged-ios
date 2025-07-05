import Combine

class MockNetworkMonitor: NetworkMonitor {
    var connectionStatus: AnyPublisher<Bool, Never> { Empty().eraseToAnyPublisher() }
    
    var isConnected: Bool { false }
}
