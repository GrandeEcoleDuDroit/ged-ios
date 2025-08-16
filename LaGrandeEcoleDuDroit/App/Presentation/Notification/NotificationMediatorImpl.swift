import UserNotifications

class NotificationMediatorImpl: NotificationMediator {
    private let notificationMessageManager: NotificationMessageManager
    
    init(notificationMessageManager: NotificationMessageManager) {
        self.notificationMessageManager = notificationMessageManager
    }
    
    func presentNotification(userInfo: [AnyHashable : Any], completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let typeString = userInfo["type"] as? String,
              let type = FcmDataType(rawValue: typeString) else {
            completionHandler([])
            return
        }
        
        switch type {
            case .message: notificationMessageManager.presentNotification(
                userInfo: userInfo,
                completionHandler: completionHandler
            )
        }
    }
    
    func receiveNotification(userInfo: [AnyHashable : Any]) {
        guard let typeString = userInfo["type"] as? String,
              let type = FcmDataType(rawValue: typeString) else {
            return
        }
        
        switch type {
            case .message: notificationMessageManager.receiveNotification(userInfo: userInfo)
        }
    }
}
