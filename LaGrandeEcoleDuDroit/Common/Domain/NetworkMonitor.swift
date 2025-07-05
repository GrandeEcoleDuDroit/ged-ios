import Combine

protocol NetworkMonitor {
    var connectionStatus: AnyPublisher<Bool, Never> { get }
    var isConnected: Bool { get }
}
