import Foundation
import Combine

class BlockedUserRepositoryImpl: BlockedUserRepository {
    private let blockedUserLocalDataSource: BlockedUserLocalDataSource
    private let blockedUserRemoteDataSource: BlockedUserRemoteDataSource
    
    private let tag = String(describing: BlockedUserRepositoryImpl.self)
    private let blockedUserEventsSubject = PassthroughSubject<BlockUserEvent, Never>()
    var blockedUserEvents: AnyPublisher<BlockUserEvent, Never> {
        blockedUserEventsSubject.eraseToAnyPublisher()
    }
    
    private let blockedUsersSubject: CurrentValueSubject<[String: BlockedUser], Never>
    var blockedUsers: AnyPublisher<[String: BlockedUser], Never> {
        blockedUsersSubject.eraseToAnyPublisher()
    }
    var currentBlockedUsers: [String: BlockedUser] {
        blockedUsersSubject.value
    }
    
    init(
        blockedUserLocalDataSource: BlockedUserLocalDataSource,
        blockedUserRemoteDataSource: BlockedUserRemoteDataSource
    ) {
        self.blockedUserLocalDataSource = blockedUserLocalDataSource
        self.blockedUserRemoteDataSource = blockedUserRemoteDataSource
        let blockedUsers = blockedUserLocalDataSource.getBlockedUsers()
        self.blockedUsersSubject = .init(blockedUsers)
    }
    
    func getRemoteBlockedUsers(currentUserId: String) async throws -> [String: BlockedUser] {
        do {
            return try await blockedUserRemoteDataSource.getBlockedUsers(currentUserId: currentUserId)
                .reduce(into: [String: BlockedUser]()) { result, element in
                    result[element.userId] = element
                }
        } catch {
            e(tag, "Error getting blocked users of user \(currentUserId)", error)
            throw error
        }
    }
    
    func getLocalBlockedUsers() -> [String: BlockedUser] {
        blockedUserLocalDataSource.getBlockedUsers()
    }
    
    func addBlockedUser(currentUserId: String, blockedUser: BlockedUser) async throws {
        do {
            try await blockedUserRemoteDataSource.addBlockedUser(currentUserId: currentUserId, blockedUser: blockedUser)
            try blockedUserLocalDataSource.addBlockedUser(blockedUser: blockedUser)
            blockedUserEventsSubject.send(.block(blockedUser))
            emitBlockedUsers()
        } catch {
            e(tag, "Error adding blocked user \(blockedUser.userId) for user \(currentUserId)", error)
            throw error
        }
    }
    
    func addLocalBlockedUser(blockedUser: BlockedUser) throws {
        try blockedUserLocalDataSource.addBlockedUser(blockedUser: blockedUser)
        emitBlockedUsers()
    }
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        do {
            try await blockedUserRemoteDataSource.removeBlockedUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
            try blockedUserLocalDataSource.removeBlockedUser(userId: blockedUserId)
            blockedUserEventsSubject.send(.unblock(blockedUserId: blockedUserId))
            emitBlockedUsers()
        } catch {
            e(tag, "Error removing blocked user \(blockedUserId) for current user \(currentUserId)", error)
            throw error
        }
    }
    
    func removeLocalBlockedUser(blockedUserId: String) throws {
        try blockedUserLocalDataSource.removeBlockedUser(userId: blockedUserId)
        emitBlockedUsers()
    }
    
    func deleteLocalBlockedUsers() {
        blockedUserLocalDataSource.deleteAll()
    }
    
    private func emitBlockedUsers() {
        let blockedUsers = blockedUserLocalDataSource.getBlockedUsers()
        blockedUsersSubject.send(blockedUsers)
    }
}
