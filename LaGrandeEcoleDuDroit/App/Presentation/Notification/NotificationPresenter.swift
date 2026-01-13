import UserNotifications

protocol NotificationPresenter {
    func presentNotification(
        userInfo: [AnyHashable : Any],
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    )
    
    func receiveNotification(userInfo: [AnyHashable : Any])
}
