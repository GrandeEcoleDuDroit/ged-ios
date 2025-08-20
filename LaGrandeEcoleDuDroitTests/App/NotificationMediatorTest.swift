import Testing
import UserNotifications
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class NotificationMediatorTest {
    @Test
    func presentNotification_should_redirect_to_the_right_notif_manager() {
        // Give
        let messageNotifManager = MessageNotifManager()
        let useCase = NotificationMediatorImpl(messageNotificationManager: messageNotifManager)
        let userInfo = getUserInfo()
        
        // When
        useCase.presentNotification(userInfo: userInfo, completionHandler: { _ in })
        
        // Then
        #expect(messageNotifManager.isPresented)
    }
    
    @Test
    func receiveNotification_should_redirect_to_the_right_notif_manager() {
        // Give
        let messageNotifManager = MessageNotifManager()
        let useCase = NotificationMediatorImpl(messageNotificationManager: messageNotifManager)
        let userInfo = getUserInfo()
        
        // When
        useCase.receiveNotification(userInfo: userInfo)
        
        // Then
        #expect(messageNotifManager.isReceived)
    }
}

private func getUserInfo() -> [AnyHashable: Any] {
    return ["type": FcmDataType.message.rawValue]
}

private class MessageNotifManager: MockMessageNotificationManager {
    var isPresented = false
    var isReceived = false
        
    override func presentNotification(userInfo: [AnyHashable : Any], completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        isPresented = true
    }
    
    override func receiveNotification(userInfo: [AnyHashable : Any]) {
        isReceived = true
    }
}
