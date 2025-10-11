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
    
    func blockUser(currentUserId: String, userId: String) async throws {
        try await blockedUserRemoteDataSource.blockUser(currentUserId: currentUserId, userId: userId)
        let blockedUserIds = blockedUserLocalDataSource.blockUser(userId: userId)
        blockedUserIdsSubject.send(blockedUserIds)
        blockedUserEventsSubject.send(.block(userId: userId))
    }
    
    func unblockUser(currentUserId: String, userId: String) async throws {
        try await blockedUserRemoteDataSource.unblockUser(currentUserId: currentUserId, userId: userId)
        let blockedUserIds = blockedUserLocalDataSource.unblockUser(userId: userId)
        blockedUserIdsSubject.send(blockedUserIds)
        blockedUserEventsSubject.send(.unblock(userId: userId))
    }
}
