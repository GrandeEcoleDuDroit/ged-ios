import Foundation
import Network
import Combine

class NetworkMonitorImpl: NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var connectionStatusSubject = PassthroughSubject<Bool, Never>()

    var connectionStatus: AnyPublisher<Bool, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.connectionStatusSubject.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
