import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class SendMessageNotificationUseCaseTest {
    @Test
    func sendMessageNotification_should_send_notification() async {
        // Given
        let verifyNotificationSent = TestNotificationApi()
        let userPresent = UserPresent()
        
        let useCase = SendMessageNotificationUseCase(
            notificationApi: verifyNotificationSent,
            userRepository: userPresent
        )
        
        // When
        await useCase.execute(notification: notificationMessageFixture)
        
        // Then
        #expect(verifyNotificationSent.isSent)
    }
    
    @Test
    func sendMessageNotification_should_do_nothing_when_current_user_not_found() async {
        // Given
        let verifyNotificationSent = TestNotificationApi()
        let userNotPresent = UserNotPresent()
        
        let useCase = SendMessageNotificationUseCase(
            notificationApi: verifyNotificationSent,
            userRepository: userNotPresent
        )
        
        // When
        await useCase.execute(notification: notificationMessageFixture)
        
        // Then
        #expect(!verifyNotificationSent.isSent)
    }
}

private class TestNotificationApi: MockNotificationApi {
    var isSent = false
    
    override func sendNotification<T>(
        recipientId: String,
        fcmMessage: FcmMessage<T>
    ) async where T : Encodable {
        isSent = true
    }
}

private class UserPresent: MockUserRepository {
    override var currentUser: User? {
        userFixture
    }
}

private class UserNotPresent: MockUserRepository {
    override var currentUser: User? {
        nil
    }
}
