import UserNotifications

class MessageNotificationPresenter: NotificationPresenter {
    private let navigationRequestUseCase: NavigationRequestUseCase
    private let routeRepository: RouteRepository
    private let tag = String(describing: MessageNotificationPresenter.self)
    
    init(
        navigationRequestUseCase: NavigationRequestUseCase,
        routeRepository: RouteRepository,
    ) {
        self.navigationRequestUseCase = navigationRequestUseCase
        self.routeRepository = routeRepository
    }
    
    func presentNotification(
        userInfo: [AnyHashable : Any],
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        guard let messageNotification = parseMessageNotification(userInfo: userInfo) else {
            completionHandler([])
            return
        }
        
        if !isCurrentChatView(conversationId: messageNotification.conversation.id) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([])
        }
    }
    
    func receiveNotification(userInfo: [AnyHashable : Any]) {
        guard let messageNotification = parseMessageNotification(userInfo: userInfo) else { return }
        let routeToNavigate = RouteToNavigate(
            mainRoute: MessageMainRoute.conversation,
            routes: [MessageRoute.chat(conversation: messageNotification.conversation)]
        )
        navigationRequestUseCase.navigate(to: routeToNavigate)
    }
    
    func clearNotifications(conversationId: String) {
        let center = UNUserNotificationCenter.current()
        let prefix = MessageNotificationUtils.formatNotificationIdPrefix(conversationId: conversationId)

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
        
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    private func isCurrentChatView(conversationId: String) -> Bool {
        guard let messageRoute = routeRepository.currentRoute as? MessageRoute else {
            return false
        }
           
        return switch messageRoute {
            case .chat(let conversation): conversation.id == conversationId
            default: false
        }
    }
    
    private func parseMessageNotification(userInfo: [AnyHashable : Any]) -> MessageNotification? {
        guard let dataValue = userInfo["value"] as? String,
              let dataValueString = try? JSONDecoder().decode(String.self, from: dataValue.data(using: .utf8)!)
        else {
            return nil
        }

        let remoteMessageNotification = try? JSONDecoder().decode(RemoteMessageNotification.self, from: dataValueString.data(using: .utf8)!)
        return remoteMessageNotification?.toMessageNotification()
    }
}
