protocol UserOracleApi {
    func createUser(user: OracleUser) async throws
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws
}
