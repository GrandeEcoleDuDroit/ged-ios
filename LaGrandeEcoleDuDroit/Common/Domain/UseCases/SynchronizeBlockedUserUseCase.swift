class SynchronizeBlockedUsersUseCase {
    private let blockedUserRepository: BlockedUserRepository
    private let userRepository: UserRepository
    
    init(
        blockedUserRepository: BlockedUserRepository,
        userRepository: UserRepository
    ) {
        self.blockedUserRepository = blockedUserRepository
        self.userRepository = userRepository
    }
    
    func execute() async throws {
        guard let currentUserId = userRepository.currentUser?.id else { return }
        let remoteBlockedUserIds = try await blockedUserRepository.getRemoteBlockedUserIds(currentUserId: currentUserId)
        let localBlockedUserIds = blockedUserRepository.getLocalBlockedUserIds()
        
        let usersToBlock = remoteBlockedUserIds.subtracting(localBlockedUserIds)
        let usersToUnblock = localBlockedUserIds.subtracting(remoteBlockedUserIds)
        
        for userId in usersToBlock {
            try await blockedUserRepository.blockUser(currentUserId: currentUserId, userId: userId)
        }
        
        for userId in usersToUnblock {
            try await blockedUserRepository.unblockUser(currentUserId: currentUserId, userId: userId)
        }
    }
}
