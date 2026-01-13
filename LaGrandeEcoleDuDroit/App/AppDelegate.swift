import FirebaseCore
import SwiftUI
import Firebase
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    private lazy var notificationMediator = AppInjector.shared.resolve(NotificationMediator.self)
    private let tag = String(describing: AppDelegate.self)
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        FirebaseApp.configure()
        configureFirestoreDb()
        registerForPushNotifications(application: application)
        runStartupTasks()
        return true
    }
    
    private func configureFirestoreDb() {
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings()
        db.clearPersistence()
        db.settings = settings
    }
    
    private func runStartupTasks() {
        let startupMessageTask = MessageInjector.shared.resolve(StartupMessageTask.self)
        let startupAnnouncementTask = NewsInjector.shared.resolve(StartupAnnouncementTask.self)
        let startupMissionTask = MissionInjector.shared.resolve(StartupMissionTask.self)
        
        startupMessageTask.run()
        startupAnnouncementTask.run()
        startupMissionTask.run()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        e(tag, "Error registering remote notifications", error)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        notificationMediator.presentNotification(userInfo: notification.request.content.userInfo, completionHandler: completionHandler)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        notificationMediator.receiveNotification(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    private func registerForPushNotifications(application: UIApplication) {
        let fcmManager = AppInjector.shared.resolve(FcmManager.self)
        Messaging.messaging().delegate = fcmManager

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}
