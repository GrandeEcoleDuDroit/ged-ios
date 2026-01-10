import Combine

protocol BlockedUserRepository {
    var blockedUserEvents: AnyPublisher<BlockUserEvent, Never> { get }
    
    var blockedUserIds: AnyPublisher<Set<String>, Never> { get }
    
    var currentBlockedUserIds: Set<String> { get }
    
    func getRemoteBlockedUserIds(currentUserId: String) async throws -> Set<String>
    
    func getLocalBlockedUserIds() -> Set<String>
    
    func addBlockedUser(currentUserId: String, blockedUserId: String) async throws
    
    func addLocalBlockedUser(blockedUserId: String) async
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws
    
    func removeLocalBlockedUser(blockedUserId: String) async
    
    func deleteLocalBlockedUsers() async
}
