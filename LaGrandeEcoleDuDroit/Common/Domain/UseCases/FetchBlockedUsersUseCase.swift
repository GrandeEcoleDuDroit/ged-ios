class FetchBlockedUsersUseCase {
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
        let remoteBlockedUserMap = try await blockedUserRepository.getRemoteBlockedUsers(currentUserId: currentUserId)
        let localBlockedUserMap = blockedUserRepository.currentBlockedUsers
        
        let blockedUserToAdd = remoteBlockedUserMap.filter { localBlockedUserMap[$0.key] == nil }.values
        let blockedUserToRemove = localBlockedUserMap.filter { remoteBlockedUserMap[$0.key] == nil }.values
        
        for blockedUser in blockedUserToAdd {
            try blockedUserRepository.addLocalBlockedUser(blockedUser: blockedUser)
        }
        
        for blockedUser in blockedUserToRemove {
            try blockedUserRepository.removeLocalBlockedUser(blockedUserId: blockedUser.userId)
        }
    }
}
