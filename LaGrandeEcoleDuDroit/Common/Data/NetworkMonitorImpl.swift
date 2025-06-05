import Foundation
import Network
import Combine

class NetworkMonitorImpl: NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var connectedPublisher = CurrentValueSubject<Bool, Never>(false)

    var connected: AnyPublisher<Bool, Never> {
        connectedPublisher.eraseToAnyPublisher()
    }

    var isConnected: Bool {
        connectedPublisher.value
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.connectedPublisher.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
