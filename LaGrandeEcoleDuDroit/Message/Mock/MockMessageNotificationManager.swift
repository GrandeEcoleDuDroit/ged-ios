import UserNotifications

class MockMessageNotificationManager: MessageNotificationManager {
    
    override init(
        navigationRequestUseCase: NavigationRequestUseCase = MockNavigationRequestUseCase(),
        routeRepository: any RouteRepository = MockRouteRepository()
    ) {
        super.init(
            navigationRequestUseCase: navigationRequestUseCase,
            routeRepository: routeRepository
        )
    }
    
    override func presentNotification(userInfo: [AnyHashable : Any], completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {}
    
    override func receiveNotification(userInfo: [AnyHashable : Any]) {}
    
    override func clearNotifications(conversationId: String) {}
}
