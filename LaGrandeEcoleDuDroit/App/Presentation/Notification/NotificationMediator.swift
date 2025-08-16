import UserNotifications

protocol NotificationMediator {
    func presentNotification(userInfo: [AnyHashable : Any], completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)

    func receiveNotification(userInfo: [AnyHashable : Any])
}
