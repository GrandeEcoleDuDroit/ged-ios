protocol TokenProvider {
    func getAuthToken() async -> String?
}
