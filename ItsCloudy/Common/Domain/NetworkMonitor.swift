import Combine

protocol NetworkMonitor {
    var connected: AnyPublisher<Bool, Never> { get }
    var isConnected: Bool { get }
}
