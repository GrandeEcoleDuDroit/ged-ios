import Combine

protocol BlockedUserRepository {
    var blockedUserEvents: AnyPublisher<BlockUserEvent, Never> { get }
    
    var blockedUserIds: AnyPublisher<Set<String>, Never> { get }
    
    func getRemoteBlockedUserIds(currentUserId: String) async throws -> Set<String>
    
    func getLocalBlockedUserIds() -> Set<String>
    
    func blockUser(currentUserId: String, userId: String) async throws
    
    func unblockUser(currentUserId: String, userId: String) async throws
}
