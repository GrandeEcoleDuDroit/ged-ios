import Testing
import UserNotifications
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class NotificationMessageManagerTest {
    @Test
    func presentNotification_should_display_notification_when_is_not_current_view() {
        // Given
        let emptyNavigationRequestUseCase = EmptyNavigationRequestUseCase()
        let nilCurrentRoute = NilCurrentRoute()
        let userInfo: [AnyHashable : Any] = [:]
        var result: UNNotificationPresentationOptions = []
        
        let useCase = MessageNotificationPresenter(
            navigationRequestUseCase: emptyNavigationRequestUseCase,
            routeRepository: nilCurrentRoute
        )
        
        // When
        useCase.presentNotification(
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
        let userInfo = getUserInfo(
            conversation: conversationFixture,
            message: messageFixture.toMessageContent()
        )
        var result: UNNotificationPresentationOptions = []
        
        let useCase = MessageNotificationPresenter(
            navigationRequestUseCase: MockNavigationRequestUseCase(),
            routeRepository: chatCurrentRoute
        )
        
        // When
        useCase.presentNotification(
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
        let userInfo = getUserInfo(
            conversation: conversationFixture,
            message: messageFixture.toMessageContent()
        )
        let expectedResult = (
            MessageMainRoute.conversation,
            [MessageRoute.chat(conversation: conversationFixture)]
        )
        let useCase = MessageNotificationPresenter(
            navigationRequestUseCase: navigate,
            routeRepository: nilCurrentRoute
        )
        
        // When
        useCase.receiveNotification(userInfo: userInfo)
        
        // Then
        let mainRoute = navigate.navigatedRoute?.mainRoute as? MessageMainRoute
        let routes = navigate.navigatedRoute?.routes.map { $0 as? MessageRoute }        
        
        #expect(
            mainRoute == expectedResult.0 &&
            routes == expectedResult.1
        )
    }
}

private func getUserInfo(conversation: Conversation, message: MessageNotification.MessageContent) -> [AnyHashable: Any] {
    let jsonEncoder = JSONEncoder()
    guard let conversationData = try? jsonEncoder.encode(conversation),
          let conversationJsonString = String(data: conversationData, encoding: .utf8),
          let messageData = try? jsonEncoder.encode(message),
          let messageJsonString = String(data: messageData, encoding: .utf8) else {
        return [:]
    }

    let valueString = "{\"conversation\": \(conversationJsonString), \"message\": \(messageJsonString)}"

    return ["value": valueString]
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
