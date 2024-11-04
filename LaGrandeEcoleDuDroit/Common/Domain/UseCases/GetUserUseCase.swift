class GetUserUseCase {
    private let userRemoteRepository: UserRemoteRepository = UserRemoteRepositoryImpl()
    
    func executre(userId: String) async -> User? {
        do {
            return try await userRemoteRepository.getUser(userId: userId)
        } catch {
            return nil
        }
    }
}
