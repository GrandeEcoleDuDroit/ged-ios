import Foundation
import Network
import Combine

class NetworkMonitorImpl: NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var connectionStatusSubject = CurrentValueSubject<Bool, Never>(false)

    var connectionStatus: AnyPublisher<Bool, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }

    var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            self?.connectionStatusSubject.send(connected)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
