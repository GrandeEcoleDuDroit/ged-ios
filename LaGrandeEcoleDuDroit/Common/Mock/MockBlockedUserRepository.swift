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
    
    func blockUser(currentUserId: String, userId: String) async throws {}
    
    func unblockUser(currentUserId: String, userId: String) async throws {}
}
