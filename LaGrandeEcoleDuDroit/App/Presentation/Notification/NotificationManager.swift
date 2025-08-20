import UserNotifications

protocol NotificationManager {
    func presentNotification(
        userInfo: [AnyHashable : Any],
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    )
    
    func receiveNotification(userInfo: [AnyHashable : Any])
}
