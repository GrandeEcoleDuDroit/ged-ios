import UserNotifications

class NotificationMessageManager: NotificationManager {
    private let navigationRequestUseCase: NavigationRequestUseCase
    private let routeRepository: RouteRepository
    private let tag = String(describing: NotificationMessageManager.self)
    
    init(
        navigationRequestUseCase: NavigationRequestUseCase,
        routeRepository: RouteRepository
    ) {
        self.navigationRequestUseCase = navigationRequestUseCase
        self.routeRepository = routeRepository
    }
    
    func presentNotification(
        userInfo: [AnyHashable : Any],
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        var presentationOptions: UNNotificationPresentationOptions = [.banner, .sound, .badge]

        if let valueString = userInfo["value"] as? String {
            do {
                let notificationMessage = try JSONDecoder().decode(NotificationMessage.self, from: valueString.data(using: .utf8)!)
                
                if isCurrentMessageView(conversationId: notificationMessage.conversation.id) {
                    presentationOptions = []
                }
            } catch {
                e(tag, "Error decoding message from userInfo", error)
            }
        }

        completionHandler(presentationOptions)
    }
    
    func receiveNotification(userInfo: [AnyHashable : Any]) {
        print("NotificationMessageManager receiveNotification: \(userInfo)")
    }
        
    private func isCurrentMessageView(conversationId: String) -> Bool {
        if let messageRoute = routeRepository.currentRoute as? MessageRoute,
           case let .chat(conversation) = messageRoute {
            conversation.id == conversationId
        } else {
            false
        }
    }
}
