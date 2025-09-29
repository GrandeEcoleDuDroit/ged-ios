import Foundation
import Combine

class BlockedUserRepositoryImpl: BlockedUserRepository {
    private let blockedUserLocalDataSource: BlockedUserLocalDataSource
    private let blockedUserRemoteDataSource: BlockedUserRemoteDataSource
    
    private let blockedUserEventsSubject = PassthroughSubject<BlockUserEvent, Never>()
    var blockedUserEvents: AnyPublisher<BlockUserEvent, Never> {
        blockedUserEventsSubject.eraseToAnyPublisher()
    }
    private let blockedUserIdsSubject = CurrentValueSubject<Set<String>, Never>([])
    var blockedUserIds: AnyPublisher<Set<String>, Never> {
        blockedUserIdsSubject.eraseToAnyPublisher()
    }
    
    init(
        blockedUserLocalDataSource: BlockedUserLocalDataSource,
        blockedUserRemoteDataSource: BlockedUserRemoteDataSource
    ) {
        self.blockedUserLocalDataSource = blockedUserLocalDataSource
        self.blockedUserRemoteDataSource = blockedUserRemoteDataSource
    }
    
    func getRemoteBlockedUserIds(currentUserId: String) async throws -> Set<String> {
        try await blockedUserRemoteDataSource.getBlockedUserIds(currentUserId: currentUserId)
    }
    
    func getLocalBlockedUserIds() -> Set<String> {
        blockedUserLocalDataSource.getBlockedUserIds()
    }
    
    func blockUser(currentUserId: String, userId: String) async throws {
        try await blockedUserRemoteDataSource.blockUser(currentUserId: currentUserId, userId: userId)
        let blockedUserIds = blockedUserLocalDataSource.blockUser(userId: userId)
        await MainActor.run {
            blockedUserIdsSubject.send(blockedUserIds)
            blockedUserEventsSubject.send(.block(userId: userId))
        }
    }
    
    func unblockUser(currentUserId: String, userId: String) async throws {
        try await blockedUserRemoteDataSource.unblockUser(currentUserId: currentUserId, userId: userId)
        let blockedUserIds = blockedUserLocalDataSource.unblockUser(userId: userId)
        await MainActor.run {
            blockedUserIdsSubject.send(blockedUserIds)
            blockedUserEventsSubject.send(.unblock(userId: userId))
        }
    }
}
