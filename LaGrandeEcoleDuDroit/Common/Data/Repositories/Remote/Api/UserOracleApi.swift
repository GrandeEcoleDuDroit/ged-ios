import Foundation

protocol UserOracleApi {
    func createUser(user: OracleUser) async throws -> (URLResponse, ServerResponse)
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws -> (URLResponse, ServerResponse)
    
    func deleteProfilePictureFileName(userId: String) async throws -> (URLResponse, ServerResponse)
}
