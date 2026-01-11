import Combine
import Foundation

protocol BlockedUserRepository {
    var blockedUserEvents: AnyPublisher<BlockUserEvent, Never> { get }
    
    var blockedUsers: AnyPublisher<[String: BlockedUser], Never> { get }
    
    var currentBlockedUsers: [String: BlockedUser] { get }
    
    func getRemoteBlockedUsers(currentUserId: String) async throws -> [String: BlockedUser]
    
    func getLocalBlockedUsers() -> [String: BlockedUser]
    
    func addBlockedUser(currentUserId: String, blockedUser: BlockedUser) async throws

    func addLocalBlockedUser(blockedUser: BlockedUser) throws
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws
    
    func removeLocalBlockedUser(blockedUserId: String) throws
    
    func deleteLocalBlockedUsers()
}
