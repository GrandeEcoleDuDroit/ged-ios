class GetBlockedUsersUseCase {
    private let blockedUserRepository: BlockedUserRepository
    private let userRepository: UserRepository
    
    init(
        blockedUserRepository: BlockedUserRepository,
        userRepository: UserRepository
    ) {
        self.blockedUserRepository = blockedUserRepository
        self.userRepository = userRepository
    }
    
    func execute() async -> [User] {
        let blockedUsers = blockedUserRepository.currentBlockedUsers.values
    
        return await withTaskGroup(of: User?.self) { [weak self] group in
            var result: [User] = []
            
            for blockedUser in blockedUsers {
                group.addTask {
                    try? await self?.userRepository.getUser(userId: blockedUser.userId)
                }
            }
            
            for await user in group {
                if let user {
                    result.append(user)
                }
            }
            
            return result
        }
    }
}
