import FirebaseCore
import Firebase
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    private let notificationMediator = AppInjector.shared.resolve(NotificationMediator.self)
    private lazy var fcmManager = AppInjector.shared.resolve(FcmManager.self)
    private lazy var fcmTokenUseCase: FcmTokenUseCase = AppInjector.shared.resolve(FcmTokenUseCase.self)
    private lazy var startupMessageTask: StartupMessageTask = MessageInjector.shared.resolve(StartupMessageTask.self)
    private let tag = String(describing: AppDelegate.self)
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        FirebaseApp.configure()
        configureFirestoreDb()
        registerForPushNotifications(application: application)
        runStartupTasks()
        listenEvents()
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
        startupMessageTask.run()
    }
    
    private func listenEvents() {
        fcmTokenUseCase.listen()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        e(tag, "Error to register remote notifications", error)
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
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = fcmManager
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {
            (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}
