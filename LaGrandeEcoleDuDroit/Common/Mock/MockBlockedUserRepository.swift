import Combine

class MockBlockedUserRepository: BlockedUserRepository {
    var blockedUserEvents: AnyPublisher<BlockUserEvent, Never> { Empty().eraseToAnyPublisher() }
    
    var blockedUsers: AnyPublisher<[String: BlockedUser], Never> { Empty().eraseToAnyPublisher() }
    
    var currentBlockedUsers: [String: BlockedUser] { [:] }
    
    func getRemoteBlockedUsers(currentUserId: String) async throws -> [String: BlockedUser]  { [:] }
    
    func getLocalBlockedUsers() -> [String: BlockedUser] { [:] }
    
    func addBlockedUser(currentUserId: String, blockedUser: BlockedUser) async throws {}

    func addLocalBlockedUser(blockedUser: BlockedUser) throws {}
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {}
    
    func removeLocalBlockedUser(blockedUserId: String) throws {}
    
    func deleteLocalBlockedUsers() {}
}
