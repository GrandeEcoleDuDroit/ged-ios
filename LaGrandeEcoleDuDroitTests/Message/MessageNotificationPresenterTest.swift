import Testing
import UserNotifications
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class MessageNotificationPresenterTest {
    @Test
    func presentNotification_should_display_notification_when_is_not_current_view() {
        // Given
        let emptyNavigationRequestUseCase = EmptyNavigationRequestUseCase()
        let nilCurrentRoute = NilCurrentRoute()
        
        var result: UNNotificationPresentationOptions = []
        let presenter = MessageNotificationPresenter(
            navigationRequestUseCase: emptyNavigationRequestUseCase,
            routeRepository: nilCurrentRoute
        )
        let userInfo = getUserInfo()
        
        // When
        presenter.presentNotification(
            userInfo: userInfo,
            completionHandler: { presentationOptions in
                result = presentationOptions
            }
        )
        
        // Then
        #expect(result == [.banner, .sound, .badge])
    }
    
    @Test
    func presentNotification_should_not_display_notification_when_is_current_view() {
        // Given
        let chatCurrentRoute = DefinedCurrentRoute(MessageRoute.chat(conversation: conversationFixture))
        let userInfo = getUserInfo()
        var result: UNNotificationPresentationOptions = []
        
        let presenter = MessageNotificationPresenter(
            navigationRequestUseCase: MockNavigationRequestUseCase(),
            routeRepository: chatCurrentRoute
        )
        
        // When
        presenter.presentNotification(
            userInfo: userInfo,
            completionHandler: { presentationOptions in
                result = presentationOptions
            }
        )
        
        // Then
        #expect(result.isEmpty)
    }
    
    @Test
    func receiveNotification_should_navigate_to_route() {
        // Given
        let navigate = Navigate()
        let nilCurrentRoute = NilCurrentRoute()
        let userInfo = getUserInfo()
        let messageNotification = MessageNotification(
            conversation: conversationFixture,
            message: messageFixture.toMessageContent()
        ).toRemote(currentUser: userFixture).toMessageNotification()

        let expectedResult = (
            MessageMainRoute.conversation,
            [MessageRoute.chat(conversation: messageNotification.conversation)]
        )
        let presenter = MessageNotificationPresenter(
            navigationRequestUseCase: navigate,
            routeRepository: nilCurrentRoute
        )
        
        // When
        presenter.receiveNotification(userInfo: userInfo)
        
        // Then
        let routes = navigate.navigatedRoute?.routes.map { $0 as? MessageRoute }
        let mainRoute = navigate.navigatedRoute?.mainRoute as? MessageMainRoute
        
        #expect(mainRoute == expectedResult.0 && routes == expectedResult.1)
    }
}

private func getUserInfo() -> [AnyHashable: Any] {
    let messageNotification = MessageNotification(
        conversation: conversationFixture,
        message: messageFixture.toMessageNotificationContent()
    ).toRemote(currentUser: userFixture)
    let jsonData = try! JSONEncoder().encode(messageNotification)
    return ["value": String(data: jsonData, encoding: .utf8)!]
}

private class EmptyNavigationRequestUseCase: NavigationRequestUseCase {}

private class Navigate: NavigationRequestUseCase {
    var navigatedRoute: RouteToNavigate? = nil
    
    override func navigate(to routeToNavigate: RouteToNavigate) {
        navigatedRoute = routeToNavigate
    }
}

private class NilCurrentRoute: MockRouteRepository {
    override var currentRoute: (any Route)? { nil }
}

private class DefinedCurrentRoute: MockRouteRepository {
    private let currentRouteValue: (any Route)
    override var currentRoute: (any Route)? { currentRouteValue }
    
    init(_ currentRouteValue: (any Route)) {
        self.currentRouteValue = currentRouteValue
    }
}
