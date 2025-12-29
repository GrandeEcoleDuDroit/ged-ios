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
    
    func blockUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserRemoteDataSource.blockUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
        let blockedUserIds = blockedUserLocalDataSource.blockUser(blockedUserId: blockedUserId)
        blockedUserIdsSubject.send(blockedUserIds)
        blockedUserEventsSubject.send(.block(userId: blockedUserId))
    }
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserRemoteDataSource.unblockUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
        let blockedUserIds = blockedUserLocalDataSource.unblockUser(blockedUserId: blockedUserId)
        blockedUserIdsSubject.send(blockedUserIds)
        blockedUserEventsSubject.send(.unblock(userId: blockedUserId))
    }
}
