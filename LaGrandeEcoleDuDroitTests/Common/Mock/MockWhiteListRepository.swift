class MockWhiteListRepository: WhiteListRepository {
    func isUserWhitelisted(email: String) async throws -> Bool { false }
}
