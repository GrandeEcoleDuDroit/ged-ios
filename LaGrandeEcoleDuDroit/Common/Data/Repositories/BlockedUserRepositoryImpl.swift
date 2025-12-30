import Foundation
import Combine

class BlockedUserRepositoryImpl: BlockedUserRepository {
    private let blockedUserLocalDataSource: BlockedUserLocalDataSource
    private let blockedUserRemoteDataSource: BlockedUserRemoteDataSource
    
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
        try await blockedUserRemoteDataSource.getBlockedUserIds(currentUserId: currentUserId)
    }
    
    func addBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserRemoteDataSource.blockUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
        blockedUserLocalDataSource.addBlockedUser(blockedUserId: blockedUserId)
        blockedUserEventsSubject.send(.block(userId: blockedUserId))
        emitBlockedUserIds()
    }
    
    func addLocalBlockedUser(blockedUserId: String) async {
        blockedUserLocalDataSource.addBlockedUser(blockedUserId: blockedUserId)
        emitBlockedUserIds()
    }
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserRemoteDataSource.removeBlockedUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
        blockedUserLocalDataSource.removeBlockedUser(blockedUserId: blockedUserId)
        blockedUserEventsSubject.send(.unblock(userId: blockedUserId))
        emitBlockedUserIds()
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
