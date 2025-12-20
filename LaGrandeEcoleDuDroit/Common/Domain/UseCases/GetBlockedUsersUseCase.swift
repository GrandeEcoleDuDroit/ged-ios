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
        guard let currentUser = userRepository.currentUser else { return [] }
        let blockedUserIds = blockedUserRepository.currentBlockedUserIds
    
        return await withTaskGroup(of: User?.self) { [weak self] group in
            var result: [User] = []
            
            for userId in blockedUserIds {
                group.addTask {
                    try? await self?.userRepository.getUser(userId: userId, tester: currentUser.tester)
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
