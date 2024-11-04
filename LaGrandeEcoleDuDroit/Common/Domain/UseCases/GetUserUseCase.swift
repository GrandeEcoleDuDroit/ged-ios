class GetUserUseCase {
    private let userRemoteRepository: UserRemoteRepository
    
    init(userRemoteRepository: UserRemoteRepository) {
        self.userRemoteRepository = userRemoteRepository
    }
    
    func executre(userId: String) async -> User? {
        do {
            return try await userRemoteRepository.getUser(userId: userId)
        } catch {
            return nil
        }
    }
}
