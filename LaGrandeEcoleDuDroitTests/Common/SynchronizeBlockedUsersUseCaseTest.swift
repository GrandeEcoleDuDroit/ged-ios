import Testing
import Combine

@testable import GrandeEcoleDuDroit

class SynchronizeBlockedUsersUseCaseTest {
    @Test
    func execute_should_block_blocked_users() async throws {
        // Given
        let usersIds = usersFixture.map { $0.id }.toSet()
        let blockedUsers = BlockedUsers(usersIds)
        let useCase = FetchBlockedUsersUseCase(
            blockedUserRepository: blockedUsers,
            userRepository: UserExist()
        )
        
        // When
        try await useCase.execute()
        
        // Then
        #expect(blockedUsers.userBlockedIds == usersIds)
    }
    
    @Test
    func execute_should_unblock_non_blocked_users() async throws {
        // Given
        let usersIds = usersFixture.map { $0.id }.toSet()
        let unblockedUsers = UnblockedUsers(usersIds)
        let useCase = FetchBlockedUsersUseCase(
            blockedUserRepository: unblockedUsers,
            userRepository: UserExist()
        )
        
        // When
        try await useCase.execute()
        
        // Then
        #expect(unblockedUsers.unblockedUserIds == usersIds)
    }
}

private class BlockedUsers: MockBlockedUserRepository {
    let usersIds: Set<String>
    var userBlockedIds: Set<String> = []
    
    init(_ usersIds: Set<String>) {
        self.usersIds = usersIds
    }
    
    override func blockUser(currentUserId: String, blockedUserId: String) async throws {
        userBlockedIds.insert(blockedUserId)
    }
    
    override func getRemoteBlockedUserIds(currentUserId: String) async throws -> Set<String> {
        usersIds
    }
}

private class UnblockedUsers: MockBlockedUserRepository {
    let usersIds: Set<String>
    var unblockedUserIds: Set<String> = []
    
    override var blockedUserIds: AnyPublisher<Set<String>, Never> {
        Just(usersIds).eraseToAnyPublisher()
    }
    
    override var currentBlockedUserIds: Set<String> {
        usersIds
    }
    
    init(_ usersIds: Set<String>) {
        self.usersIds = usersIds
    }
    
    override func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        unblockedUserIds.insert(blockedUserId)
    }
}


private class UserExist: MockUserRepository {
    override var currentUser: User? {
        userFixture
    }
}
