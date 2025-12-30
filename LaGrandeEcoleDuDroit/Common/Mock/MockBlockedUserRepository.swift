import Combine

class MockBlockedUserRepository: BlockedUserRepository {
    var blockedUserEvents: AnyPublisher<BlockUserEvent, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    var blockedUserIds: AnyPublisher<Set<String>, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    var currentBlockedUserIds: Set<String> { Set<String>() }
    
    func getRemoteBlockedUserIds(currentUserId: String) async throws -> Set<String> { Set<String>() }
    
    func addBlockedUser(currentUserId: String, blockedUserId: String) async throws {}
    
    func addLocalBlockedUser(blockedUserId: String) async {}
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {}
    
    func removeLocalBlockedUser(blockedUserId: String) async {}
    
    func deleteLocalBlockedUsers() async {}
}
