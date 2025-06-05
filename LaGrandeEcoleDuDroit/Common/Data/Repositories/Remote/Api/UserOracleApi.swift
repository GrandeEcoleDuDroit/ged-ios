protocol UserOracleApi {
    func createUser(user: OracleUser) async throws
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws
    
    func deleteProfilePictureFileName(userId: String) async throws
}
