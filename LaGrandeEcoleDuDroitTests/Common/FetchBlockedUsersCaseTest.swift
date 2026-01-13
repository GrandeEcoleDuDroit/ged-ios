import Testing
import Combine
import Foundation

@testable import GrandeEcoleDuDroit

class FetchBlockedUsersUseCaseTest {
    @Test
    func fetchBlockedUsers_should_block_missing_blocked_users() async throws {
        // Given
        let localBlockedUsers: [BlockedUser] = []
        let remoteBlockedUsers = usersFixture.map { BlockedUser(userId: $0.id, date: Date()) }
        let blockedUserRepository = TestBlockedUserRepository(
            localBlockedUsers: localBlockedUsers,
            remoteBlockedUsers: remoteBlockedUsers
        )
        let useCase = FetchBlockedUsersUseCase(
            blockedUserRepository: blockedUserRepository,
            userRepository: TestUserRepository()
        )
        
        // When
        try await useCase.execute()
        let result = blockedUserRepository.localBlockedUsers.allSatisfy { blockedUser in
            remoteBlockedUsers.contains(where: { $0.userId == blockedUser.userId })
        }
        
        // Then
        #expect(result)
    }
    
    @Test
    func fetchBlockedUsers_should_unblock_not_blocked_users() async throws {
        // Given
        let localBlockedUsers: [BlockedUser] = usersFixture.map { BlockedUser(userId: $0.id, date: Date()) }
        let remoteBlockedUsers: [BlockedUser] = []
        let blockedUserRepository = TestBlockedUserRepository(
            localBlockedUsers: localBlockedUsers,
            remoteBlockedUsers: remoteBlockedUsers
        )
        let useCase = FetchBlockedUsersUseCase(
            blockedUserRepository: blockedUserRepository,
            userRepository: TestUserRepository()
        )
        
        // When
        try await useCase.execute()
        let result = blockedUserRepository.localBlockedUsers.isEmpty
        
        // Then
        #expect(result)
    }
}

private class TestBlockedUserRepository: MockBlockedUserRepository {
    var localBlockedUsers: [BlockedUser] = []
    var remoteBlockedUsers: [BlockedUser] = []
    
    init(
        localBlockedUsers: [BlockedUser],
        remoteBlockedUsers: [BlockedUser]
    ) {
        self.localBlockedUsers = localBlockedUsers
        self.remoteBlockedUsers = remoteBlockedUsers
    }
    
    override var currentBlockedUsers: [String : BlockedUser] {
        localBlockedUsers.reduce(into: [:]) { result, user in
            result[user.userId] = user
        }
    }
    
    override func addLocalBlockedUser(blockedUser: BlockedUser) throws {
        localBlockedUsers.append(blockedUser)
    }
    
    override func removeLocalBlockedUser(blockedUserId: String) throws {
        localBlockedUsers.removeAll { $0.userId == blockedUserId }
    }
    
    override func getRemoteBlockedUsers(currentUserId: String) async throws -> [String: BlockedUser]  {
        remoteBlockedUsers.reduce(into: [:]) { result, user in
            result[user.userId] = user
        }
    }
}

private class TestUserRepository: MockUserRepository {
    override var currentUser: User? {
        userFixture
    }
}
