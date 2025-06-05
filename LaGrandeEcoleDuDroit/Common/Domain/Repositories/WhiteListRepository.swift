
protocol WhiteListRepository {
    func isUserWhitelisted(email: String) async throws -> Bool 
}
