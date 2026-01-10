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
    
    private let blockedUserIdsSubject: CurrentValueSubject<Set<String>, Never>
    var blockedUserIds: AnyPublisher<Set<String>, Never> {
        blockedUserIdsSubject.eraseToAnyPublisher()
    }
    var currentBlockedUserIds: Set<String> {
        blockedUserIdsSubject.value
    }
    
    init(
        blockedUserLocalDataSource: BlockedUserLocalDataSource,
        blockedUserRemoteDataSource: BlockedUserRemoteDataSource
    ) {
        self.blockedUserLocalDataSource = blockedUserLocalDataSource
        self.blockedUserRemoteDataSource = blockedUserRemoteDataSource
        let blockedUserIds = blockedUserLocalDataSource.getBlockedUserIds()
        self.blockedUserIdsSubject = CurrentValueSubject<Set<String>, Never>(blockedUserIds)
    }
    
    func getRemoteBlockedUserIds(currentUserId: String) async throws -> Set<String> {
        do {
            return try await blockedUserRemoteDataSource.getBlockedUserIds(currentUserId: currentUserId)
        } catch {
            e(tag, "Error getting blocked user ids of current user \(currentUserId)", error)
            return Set()
        }
    }
    
    func getLocalBlockedUserIds() -> Set<String> {
        blockedUserLocalDataSource.getBlockedUserIds()
    }
    
    func addBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        do {
            try await blockedUserRemoteDataSource.blockUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
            blockedUserLocalDataSource.addBlockedUser(blockedUserId: blockedUserId)
            blockedUserEventsSubject.send(.block(userId: blockedUserId))
            emitBlockedUserIds()
        } catch {
            e(tag, "Error adding blocked user \(blockedUserId) for current user \(currentUserId)", error)
            throw error
        }
    }
    
    func addLocalBlockedUser(blockedUserId: String) async {
        blockedUserLocalDataSource.addBlockedUser(blockedUserId: blockedUserId)
        emitBlockedUserIds()
    }
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        do {
            try await blockedUserRemoteDataSource.removeBlockedUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
            blockedUserLocalDataSource.removeBlockedUser(blockedUserId: blockedUserId)
            blockedUserEventsSubject.send(.unblock(userId: blockedUserId))
            emitBlockedUserIds()
        } catch {
            e(tag, "Error removing blocked user \(blockedUserId) for current user \(currentUserId)", error)
            throw error
        }
    }
    
    func removeLocalBlockedUser(blockedUserId: String) async {
        blockedUserLocalDataSource.removeBlockedUser(blockedUserId: blockedUserId)
        emitBlockedUserIds()
    }
    
    func deleteLocalBlockedUsers() async {
        blockedUserLocalDataSource.deleteAll()
    }
    
    private func emitBlockedUserIds() {
        let blockedUserIds = blockedUserLocalDataSource.getBlockedUserIds()
        blockedUserIdsSubject.send(blockedUserIds)
    }
}
