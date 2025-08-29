protocol TokenProvider {
    func getAuthIdToken() async -> String?
}
