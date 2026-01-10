import UserNotifications

class NotificationMediator {
    private let messageNotificationPresenter: MessageNotificationPresenter
    
    init(messageNotificationPresenter: MessageNotificationPresenter) {
        self.messageNotificationPresenter = messageNotificationPresenter
    }
    
    func presentNotification(userInfo: [AnyHashable: Any], completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        switch getType(from: userInfo) {
            case .message: messageNotificationPresenter.presentNotification(
                userInfo: userInfo,
                completionHandler: completionHandler
            )
            default: completionHandler([])
        }
    }
    
    func receiveNotification(userInfo: [AnyHashable: Any]) {
        switch getType(from: userInfo) {
            case .message: messageNotificationPresenter.receiveNotification(userInfo: userInfo)
            default: break
        }
    }
    
     private func getType(from userInfo: [AnyHashable: Any]) -> FcmDataType? {
        guard let typeString = userInfo["type"] as? String else { return nil }
        return FcmDataType(rawValue: typeString)
    }
}
