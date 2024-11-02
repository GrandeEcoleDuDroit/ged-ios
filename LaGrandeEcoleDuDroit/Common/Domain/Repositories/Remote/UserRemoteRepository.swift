protocol UserRemoteRepository {
    func createUser(user: User) async throws
}
