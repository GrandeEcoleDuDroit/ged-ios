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
        if let notificationMessage = parseNotificationMessage(userInfo: userInfo) {
            if isCurrentMessageView(conversationId: notificationMessage.conversation.id) {
                presentationOptions = []
            }
        }
        completionHandler(presentationOptions)
    }
    
    func receiveNotification(userInfo: [AnyHashable : Any]) {
        guard let notificationMessage = parseNotificationMessage(userInfo: userInfo) else { return }
        let routeToNavigate = RouteToNavigate(
            mainRoute: MessageMainRoute.conversation,
            routes: [MessageRoute.chat(conversation: notificationMessage.conversation)]
        )
        navigationRequestUseCase.navigate(to: routeToNavigate)
    }
    
    func clearNotifications(conversationId: String) {
        let center = UNUserNotificationCenter.current()
        let prefix = NotificationMessageUtils.getNotificationIdPrefix(conversationId: conversationId)

        center.getDeliveredNotifications { notifications in
            let matchingIds = notifications
                .map { $0.request.identifier }
                .filter { $0.hasPrefix(prefix) }
            
            center.removeDeliveredNotifications(withIdentifiers: matchingIds)
        }
        
        center.getPendingNotificationRequests { requests in
            let matchingIds = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(prefix) }
            
            center.removeDeliveredNotifications(withIdentifiers: matchingIds)
        }
    }
        
    private func isCurrentMessageView(conversationId: String) -> Bool {
        if let messageRoute = routeRepository.currentRoute as? MessageRoute,
           case let .chat(conversation) = messageRoute {
            conversation.id == conversationId
        } else {
            false
        }
    }
    
    private func parseNotificationMessage(userInfo: [AnyHashable : Any]) -> NotificationMessage? {
        guard let valueString = userInfo["value"] as? String else { return nil }
        let notificationMessage = try? JSONDecoder().decode(
            NotificationMessage.self,
            from: valueString.data(using: .utf8)!
        )
        
        return notificationMessage
    }
}
