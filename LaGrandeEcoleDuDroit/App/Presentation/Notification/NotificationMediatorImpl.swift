import UserNotifications

class NotificationMediatorImpl: NotificationMediator {
    private let messageNotificationManager: MessageNotificationManager
    
    init(messageNotificationManager: MessageNotificationManager) {
        self.messageNotificationManager = messageNotificationManager
    }
    
    func presentNotification(userInfo: [AnyHashable : Any], completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let typeString = userInfo["type"] as? String,
              let type = FcmDataType(rawValue: typeString)
        else {
            completionHandler([])
            return
        }
        
        switch type {
            case .message: messageNotificationManager.presentNotification(
                userInfo: userInfo,
                completionHandler: completionHandler
            )
        }
    }
    
    func receiveNotification(userInfo: [AnyHashable : Any]) {
        guard let typeString = userInfo["type"] as? String,
              let type = FcmDataType(rawValue: typeString)
        else {
            return
        }
        
        switch type {
            case .message: messageNotificationManager.receiveNotification(userInfo: userInfo)
        }
    }
}
